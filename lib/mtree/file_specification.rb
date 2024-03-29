# frozen_string_literal: true

require 'etc'

module Mtree
  class FileSpecification # rubocop:disable Metrics/ClassLength
    # VALID_ATTRIBUTES = %i[cksum device flags gid gname link md5 mode nlink nochange optional rmd160 sha1 sha256 sha384 sha512 size tags time type uid uname].freeze
    VALID_ATTRIBUTES = %i[gid gname link mode nochange optional type uid uname].freeze

    VALID_ATTRIBUTES.each do |attr|
      define_method(attr) do
        @attributes[attr]
      end

      define_method("#{attr}=") do |value|
        @attributes[attr] = value
      end
    end

    attr_accessor :filename, :relative_path, :children

    def initialize(filename, attributes = {})
      @filename = filename
      @relative_path = filename
      if (invalid_keys = attributes.keys - VALID_ATTRIBUTES) != []
        raise "Unsupported attribute: #{invalid_keys.first}"
      end

      @attributes = attributes
      @children = []
    end

    def match?(root) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      res = true
      problems = []

      begin
        @attributes.each do |attr, expected|
          actual = send("current_#{attr}", root)

          problems << { attr: attr, expected: expected, actual: actual } if expected != actual
        end
      rescue Errno::ENOENT
        puts "#{relative_path} missing"
        res = false
      end

      if problems.any? && !nochange
        puts("#{relative_path}:")
        puts(problems.map { |problem| format("\t%<attr>s (%<expected>s, %<actual>s)", problem) })
        res = false
      end

      children.each do |child|
        res &= child.match?(root)
      end

      res
    end

    def each(&block)
      yield(self)

      children.each do |child|
        child.each(&block)
      end
    end

    def enforce(root)
      if exist?(root)
        update(root) unless nochange
      else
        create(root)
      end

      children.each do |child|
        child.enforce(root)
      end
    end

    def exist?(root)
      current_type(root) == type
    end

    def create(root)
      case type
      when 'dir'  then FileUtils.mkdir_p(full_filename(root))
      when 'file' then FileUtils.touch(full_filename(root))
      when 'link'
        FileUtils.rm_rf(full_filename(root))
        FileUtils.ln_s(link, full_filename(root))
      end
      update(root)
    end

    def update(root)
      FileUtils.chown(uname, gname, full_filename(root)) if uname || gname
      FileUtils.chmod(mode, full_filename(root)) if mode
    end

    def <<(child)
      children << child

      child.relative_path = File.join(relative_path, child.filename)
    end

    def leaves!
      if children.any?
        self.nochange = true
        children.each(&:leaves!)
      end
      self
    end

    def symlink_to!(destination)
      unless nochange
        @attributes = {
          type: 'link',
          link: File.join(destination, relative_path).sub(%r{/\.$}, '').sub(%r{/\./}, '/'),
        }
      end
      children.each do |child|
        child.symlink_to!(destination)
      end
      self
    end

    def to_s(options = {})
      descendent = ''
      if children.any?
        descendent = children.map do |child|
          child.to_s(options)
        end.join
        descendent.gsub!(/^/, '    ') if options[:indent]
      end

      "#{filename} #{attributes}\n#{descendent}..\n"
    end

    def attributes # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      parts = []

      parts << format('gid=%d', gid)     if gid
      parts << format('gname=%s', gname) if gname
      parts << format('link=%s', link)   if link
      parts << format('mode=0%o', mode)  if mode
      parts << 'nochange'                if nochange
      parts << 'optional'                if optional
      parts << format('type=%s', type)   if type
      parts << format('uid=%d', uid)     if uid
      parts << format('uname=%s', uname) if uname

      parts.join(' ')
    end

    private

    def full_filename(root)
      File.join(root, @relative_path)
    end

    def file_stat(root)
      File.stat(full_filename(root))
    end

    def current_gid(root)
      file_stat(root).gid
    end

    def current_gname(root)
      Etc.getgrgid(current_gid(root)).name
    end

    def current_mode(root)
      file_stat(root).mode & 0o7777
    end

    def current_nochange(_root)
      true
    end

    def current_type(root)
      t = file_stat(root).ftype

      case t
      when 'blockSpecial'     then 'block'
      when 'characterSpecial' then 'char'
      when 'directory'        then 'dir'
      else t
      end
    rescue Errno::ENOENT
      nil
    end

    def current_uid(root)
      file_stat(root).uid
    end

    def current_uname(root)
      Etc.getpwuid(current_uid(root)).name
    end
  end
end
