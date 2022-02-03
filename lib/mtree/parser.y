class Mtree::Parser
rule
  target: expressions { if @path_components.any? then raise 'Malformed specifications' end }
        |

  expressions: expressions expression
             | expression

  expression: SET attributes LINE_BREAK         { @defaults.merge!(val[1]) }
            | IDENTIFIER attributes LINE_BREAK  {
                                                  spec = Mtree::FileSpecification.new(val[0], @defaults.merge(val[1]))
                                                  @specifications ||= spec
                                                  @path_components.last << spec if @path_components.last
                                                  @path_components.push(spec)
                                                }
            | DOT_DOT LINE_BREAK                { @path_components.pop }
            | LINE_BREAK

  attributes: attributes attribute { result = val[0].merge(val[1]) }
            |                      { result = {} }

  attribute: GID      { result = { gid:      Integer(val[0]) } }
           | GNAME    { result = { gname:    val[0] } }
           | MODE     { result = { mode:     Integer(val[0], 8) } }
           | NOCHANGE { result = { nochange: true } }
           | TAGS     { result = {} }
           | TYPE     { result = { type:     val[0] } }
           | UID      { result = { uid:      Integer(val[0]) } }
           | UNAME    { result = { uname:    val[0] } }
end


---- header

require 'strscan'

---- inner

attr_accessor :yydebug
attr_accessor :defaults

attr_reader :specifications

def initialize
  super
  @defaults = {}
  @path_components = []
  @specifications = nil
end

def parse(text)
  s = StringScanner.new(text)

  tokens = []
  until s.eos? do
    case
    when s.scan(/#.*/);                   # Ignore comment
    when s.scan(/[[:blank:]]+/);          # Ignore blanks
    when s.scan(/\n/);                    tokens << [:LINE_BREAK, s.matched]
    when s.scan(/\.\./);                  tokens << [:DOT_DOT, s.matched]
    when s.scan(/\/set\b/);               tokens << [:SET, s.matched]
    when s.scan(/gid=([[:digit:]]+)/);    tokens << [:GID, s[1]]
    when s.scan(/gname=([[:alnum:]]+)/);  tokens << [:GNAME, s[1]]
    when s.scan(/mode=([[:digit:]]+)/);   tokens << [:MODE, s[1]]
    when s.scan(/nochange\b/);            tokens << [:NOCHANGE, s[1]]
    when s.scan(/tags=([[:print:]]+)\b/); tokens << [:TAGS, s[1]]
    when s.scan(/type=(dir|file)/);       tokens << [:TYPE, s[1]]
    when s.scan(/uid=([[:digit:]]+)/);    tokens << [:UID, s[1]]
    when s.scan(/uname=([[:alnum:]]+)/);  tokens << [:UNAME, s[1]]
    when s.scan(/[^[:space:]]+/);         tokens << [:IDENTIFIER, s.matched]
    else
      raise "No match: #{s.rest}"
    end
  end

  define_singleton_method(:next_token) { tokens.shift }

  tokens << [false, false]

  # tokens.each do |t|
  #   puts t.inspect
  # end

  do_parse
end

def parse_file(filename)
  parse(File.read(filename))
end
