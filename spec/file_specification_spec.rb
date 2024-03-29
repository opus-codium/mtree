# frozen_string_literal: true

RSpec.describe Mtree::FileSpecification do
  let(:root) { '/' }

  subject do
    Mtree::FileSpecification.new('/', uid: 0)
  end

  describe '#new' do
    it { expect { subject }.to_not raise_error }
  end

  describe '#uid' do
    it { expect(subject.uid).to eq(0) }
  end

  describe '#uid=' do
    before do
      subject.uid = 1000
    end

    it { expect(subject.uid).to eq(1000) }
  end

  describe '#match?' do
    describe 'with a matching specification' do
      describe 'gid' do
        subject do
          Mtree::FileSpecification.new('.', gid: 0)
        end

        it { expect(subject.match?(root)).to be_truthy }
      end

      describe 'gname' do
        subject do
          Mtree::FileSpecification.new('.', gname: 'wheel')
        end

        it do
          pending('Not portable: GNU/Linux does not have a wheel group')
          expect(subject.match?(root)).to be_truthy
        end
      end

      describe 'uid' do
        subject do
          Mtree::FileSpecification.new('.', uid: 0)
        end

        it { expect(subject.match?(root)).to be_truthy }
      end

      describe 'uname' do
        subject do
          Mtree::FileSpecification.new('.', uname: 'root')
        end

        it { expect(subject.match?(root)).to be_truthy }
      end
    end

    describe 'with a non-matching specification' do
      subject do
        Mtree::FileSpecification.new('.', uid: 65_534)
      end

      it { expect(subject.match?(root)).to be_falsey }
    end
  end

  describe '#each' do
    let(:root) do
      Mtree::FileSpecification.new('.', uname: 'root')
    end

    let(:leaf) do
      Mtree::FileSpecification.new('leaf', uname: 'romain')
    end

    let(:nodes) { [] }

    before do
      root << leaf

      root.each do |entry|
        nodes << entry
      end
    end

    it { expect(nodes).to eq([root, leaf]) }
  end

  describe '#leaves!' do
    let(:root) do
      Mtree::FileSpecification.new('.', uname: 'root')
    end

    let(:leaf) do
      Mtree::FileSpecification.new('leaf', uname: 'romain')
    end

    before do
      root << leaf
      root.leaves!
    end

    it { expect(root.nochange).to be_truthy }
    it { expect(leaf.nochange).to be_falsey }
  end

  describe '#symlink_to!' do
    let(:root) do
      Mtree::FileSpecification.new('.', uname: 'root')
    end

    let(:leaf) do
      Mtree::FileSpecification.new('leaf', uname: 'romain')
    end

    before do
      root << leaf
      root.symlink_to!('/target')
    end

    it { expect(root.type).to eq('link') }
    it { expect(root.link).to eq('/target') }
    it { expect(leaf.type).to eq('link') }
    it { expect(leaf.link).to eq('/target/leaf') }
  end

  describe '#attributes' do
    subject do
      Mtree::FileSpecification.new('foo', uname: 'root', gid: 1000, mode: 0o770, type: 'dir').attributes
    end

    it { expect(subject).to match('uname=root') }
    it { expect(subject).to match('gid=1000') }
    it { expect(subject).to match('mode=0770') }
    it { expect(subject).to match('type=dir') }
  end
end
