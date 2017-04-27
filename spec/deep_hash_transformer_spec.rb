RSpec.describe DeepHashTransformer do
  let(:hash) do
    {
      Integer => 123,
      :foobar => { bar: 'bar' },
      'aa_zz' => [{ 'bar' => :bar, 'a-z' => 'a-z' }]
    }
  end

  describe '#tr with `%i[underscore symbolize]`' do
    subject { DeepHashTransformer.new(hash).tr(:underscore, :symbolize) }

    it do
      is_expected.to eq(
        Integer => 123,
        :foobar => { bar: 'bar' },
        :aa_zz  => [{ bar: :bar, a_z: 'a-z' }]
      )
    end
  end

  describe '#dasherize' do
    subject { DeepHashTransformer.new(hash).dasherize }

    it do
      is_expected.to eq(
        Integer => 123,
        'foobar' => { 'bar' => 'bar' },
        'aa-zz'  => [{ 'bar' => :bar, 'a-z' => 'a-z' }]
      )
    end
  end

  describe '#identity' do
    subject { DeepHashTransformer.new(hash).identity }

    it do
      is_expected.to eq(
        Integer => 123,
        :foobar => { bar: 'bar' },
        'aa_zz' => [{ 'bar' => :bar, 'a-z' => 'a-z' }]
      )
    end
  end

  describe '#stringify' do
    subject { DeepHashTransformer.new(hash).stringify }

    it do
      is_expected.to eq(
        Integer => 123,
        'foobar' => { 'bar' => 'bar' },
        'aa_zz'  => [{ 'bar' => :bar, 'a-z' => 'a-z' }]
      )
    end
  end

  describe '#symbolize' do
    subject { DeepHashTransformer.new(hash).symbolize }

    it do
      is_expected.to eq(
        Integer => 123,
        :foobar => { bar: 'bar' },
        :aa_zz  => [{ :bar => :bar, :'a-z' => 'a-z' }]
      )
    end
  end

  describe '#underscore' do
    subject { DeepHashTransformer.new(hash).underscore }

    it do
      is_expected.to eq(
        Integer => 123,
        'foobar' => { 'bar' => 'bar' },
        'aa_zz'  => [{ 'bar' => :bar, 'a_z' => 'a-z' }]
      )
    end
  end

  it 'has a version number' do
    expect(DeepHashTransformer::VERSION).not_to be nil
  end
end
