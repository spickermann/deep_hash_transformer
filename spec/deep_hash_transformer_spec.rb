# frozen_string_literal: true

RSpec.describe DeepHashTransformer do
  subject do
    described_class.new(
      Integer => 123,
      :foobar => { bar: 'bar' },
      'aa_zz' => [{ 'bar' => :bar, 'a-z' => 'a-z' }, { 'aZ' => 'aZ' }]
    )
  end

  describe '#tr with `:underscore, :symbolize`' do
    subject { super().tr(:snake_case, :symbolize) }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        :foobar => { bar: 'bar' },
        :aa_zz => [{ bar: :bar, a_z: 'a-z' }, { a_z: 'aZ' }]
      )
    end
  end

  describe '#dasherize' do
    subject { super().dasherize }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'foobar' => { 'bar' => 'bar' },
        'aa-zz' => [{ 'bar' => :bar, 'a-z' => 'a-z' }, { 'aZ' => 'aZ' }]
      )
    end
  end

  describe '#identity' do
    subject { super().identity }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        :foobar => { bar: 'bar' },
        'aa_zz' => [{ 'bar' => :bar, 'a-z' => 'a-z' }, { 'aZ' => 'aZ' }]
      )
    end
  end

  describe '#stringify' do
    subject { super().stringify }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'foobar' => { 'bar' => 'bar' },
        'aa_zz' => [{ 'bar' => :bar, 'a-z' => 'a-z' }, { 'aZ' => 'aZ' }]
      )
    end
  end

  describe '#symbolize' do
    subject { super().symbolize }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        :foobar => { bar: 'bar' },
        :aa_zz => [{ bar: :bar, 'a-z': 'a-z' }, { aZ: 'aZ' }]
      )
    end
  end

  describe '#underscore' do
    subject { super().underscore }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'foobar' => { 'bar' => 'bar' },
        'aa_zz' => [{ 'bar' => :bar, 'a_z' => 'a-z' }, { 'aZ' => 'aZ' }]
      )
    end
  end

  describe '#snake_case' do
    subject { super().snake_case }

    it do
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'foobar' => { 'bar' => 'bar' },
        'aa_zz' => [{ 'bar' => :bar, 'a_z' => 'a-z' }, { 'a_z' => 'aZ' }]
      )
    end
  end

  it 'has a version number' do
    expect(DeepHashTransformer::VERSION).not_to be nil
  end
end
