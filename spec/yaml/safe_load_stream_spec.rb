require 'yaml'
require 'ostruct'

RSpec.describe YAMLSafeLoadStream do
  let(:multidoc_stream) { "---\nhello: world\n\n---\nhello: universe\n" }

  context 'used with a block' do
    it 'yields each document' do
      docs = []
      YAMLSafeLoadStream.safe_load_stream(multidoc_stream) do |doc|
        expect(doc).to be_a Hash
        docs << doc
      end

      expect(docs.first['hello']).to eq 'world'
      expect(docs.last['hello']).to eq 'universe'
    end

    it 'returns the result of yields as array' do
      docs = YAMLSafeLoadStream.safe_load_stream(multidoc_stream) do |doc|
        expect(doc).to be_a Hash
        doc
      end

      expect(docs.first['hello']).to eq 'world'
      expect(docs.last['hello']).to eq 'universe'
    end
  end

  context 'used without a block' do
    it 'returns an array of documents' do
      expect(YAMLSafeLoadStream.safe_load_stream(multidoc_stream)).to match [
        hash_including('hello' => 'world'),
        hash_including('hello' => 'universe')
      ]
    end
  end

  context 'with a document containing unsafe tags' do
    let(:tagged_multidoc_stream) do
      [
        ::YAML.dump('hello' => OpenStruct.new(target: 'world')),
        ::YAML.dump('hello' => OpenStruct.new(target: 'universe'))
      ].join("\n\n")
    end

    it 'raises Psych::DisallowedClass' do
      expect{YAMLSafeLoadStream.safe_load_stream(tagged_multidoc_stream)}.to raise_error(Psych::DisallowedClass, /Tried to load unspecified class/)
    end
  end
end
