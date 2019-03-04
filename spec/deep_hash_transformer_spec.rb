RSpec.describe DeepHashTransformer do
  subject do
    described_class.new(
      Integer => 123,
      :foobar => { bar: 'bar' },
      'aa_zz' => [{ 'bar' => :bar, 'a-z' => 'a-z' }]
    )
  end

  describe '#tr with `:underscore, :symbolize`' do
    subject { super().tr(:underscore, :symbolize) }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        :foobar => { bar: 'bar' },
        :aa_zz => [{ bar: :bar, a_z: 'a-z' }]
      )
    end
  end

  describe '#dasherize' do
    subject { super().dasherize }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'foobar' => { 'bar' => 'bar' },
        'aa-zz' => [{ 'bar' => :bar, 'a-z' => 'a-z' }]
      )
    end
  end

  describe '#identity' do
    subject { super().identity }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        :foobar => { bar: 'bar' },
        'aa_zz' => [{ 'bar' => :bar, 'a-z' => 'a-z' }]
      )
    end
  end

  describe '#stringify' do
    subject { super().stringify }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'foobar' => { 'bar' => 'bar' },
        'aa_zz' => [{ 'bar' => :bar, 'a-z' => 'a-z' }]
      )
    end
  end

  describe '#symbolize' do
    subject { super().symbolize }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        :foobar => { bar: 'bar' },
        :aa_zz => [{ bar: :bar, 'a-z': 'a-z' }]
      )
    end
  end

  describe '#underscore' do
    subject { super().underscore }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'foobar' => { 'bar' => 'bar' },
        'aa_zz' => [{ 'bar' => :bar, 'a_z' => 'a-z' }]
      )
    end
  end

  it 'has a version number' do
    expect(DeepHashTransformer::VERSION).not_to be nil
  end
end
