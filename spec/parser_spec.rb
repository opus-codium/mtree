RSpec.describe Mtree::Parser do
  subject do
    parser = Mtree::Parser.new
    parser.parse(mtree_specification)
    parser
  end

  context 'when given an empty specification' do
    let(:mtree_specification) do
      ''
    end

    it { expect { subject }.to_not raise_error }
  end

  context 'when given an invalid specification' do
    let(:mtree_specification) do
      'this is not an mtree specification'
    end

    it { expect { subject }.to raise_error(Racc::ParseError, /parse error on value "is" \(IDENTIFIER\)/) }
  end

  context 'when given a comment' do
    let(:mtree_specification) do
      "# foo\n"
    end

    it { expect { subject }.to_not raise_error }
  end

  context 'when given a /set' do
    let(:mtree_specification) do
      <<-MTREE
      /set uname=root gname=wheel
      MTREE
    end

    it { expect { subject }.to_not raise_error }
    it { expect(subject.defaults[:uname]).to eq 'root' }
    it { expect(subject.defaults[:gname]).to eq 'wheel' }
  end

  context 'when given an incomplete specification' do
    let(:mtree_specification) do
      <<-MTREE
      . mode=0777
      MTREE
    end

    it { expect { subject }.to raise_error(StandardError, 'Malformed specifications') }
  end

  context 'when given a complete specification' do
    let(:mtree_specification) do
      <<-MTREE
      . mode=0777
      ..
      MTREE
    end

    it { expect { subject }.to_not raise_error }
  end

  context '#parse_file' do
    let(:parser) do
      parser = Mtree::Parser.new
      parser.parse_file('spec/fixtures/BSD.sendmail.dist')
      parser
    end

    it { expect { parser }.to_not raise_error }

    context '.' do
      subject do
        parser.specifications
      end

      it { expect(subject.children.count).to eq 1 }
      it { expect(subject.filename).to eq '.' }
      it { expect(subject.relative_path).to eq '.' }
      it { expect(subject.uname).to eq 'root' }
      it { expect(subject.gname).to eq 'wheel' }
      it { expect(subject.mode).to eq 0o755 }
    end

    context './var' do
      subject do
        parser.specifications.children[0]
      end

      it { expect(subject.children.count).to eq 1 }
      it { expect(subject.filename).to eq 'var' }
      it { expect(subject.relative_path).to eq './var' }
      it { expect(subject.uname).to eq 'root' }
      it { expect(subject.gname).to eq 'wheel' }
      it { expect(subject.mode).to eq 0o755 }
    end

    context './var/spool' do
      subject do
        parser.specifications.children[0].children[0]
      end

      it { expect(subject.children.count).to eq 1 }
      it { expect(subject.filename).to eq 'spool' }
      it { expect(subject.relative_path).to eq './var/spool' }
      it { expect(subject.uname).to eq 'root' }
      it { expect(subject.gname).to eq 'wheel' }
      it { expect(subject.mode).to eq 0o755 }
    end

    context './var/spool/clientmqueue' do
      subject do
        parser.specifications.children[0].children[0].children[0]
      end

      it { expect(subject.children.count).to eq 0 }
      it { expect(subject.filename).to eq 'clientmqueue' }
      it { expect(subject.relative_path).to eq './var/spool/clientmqueue' }
      it { expect(subject.uname).to eq 'smmsp' }
      it { expect(subject.gname).to eq 'smmsp' }
      it { expect(subject.mode).to eq 0o770 }
    end
  end
end
