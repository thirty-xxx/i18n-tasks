# frozen_string_literal: true
RSpec::Matchers.define :be_i18n_keys do |expected|
  def locale_re
    /^\w{2}\b/
  end
  
  def extract_keys(actual)
    actual = Term::ANSIColor.uncolor(actual).split("\n").map(&:presence).compact
    actual = actual[3..-2]
    actual = actual.map { |row|
      row[1..-1].gsub(/(?:\s+|^)\|(?:\s+|$)/, '|').gsub(/\s+/, ' ').strip.split(/\s*\|\s*/)
    }.compact
    return [] if actual.empty?
    locale_col = 0
    key_col = 1
    actual.map { |row|
      key = [row[locale_col], row[key_col]].map(&:presence).compact.join('.')
      key = key[0..-2] if key.end_with?(':')
      key
    }.compact
  end

  match do |actual|
    expect(extract_keys(actual).sort).to eq(expected.sort)
  end

  failure_message do |actual|
    e = expected.sort
    a = extract_keys(actual).sort

    <<-MSG.strip
Expected #{e}, but had #{a}. Diff:

missing: #{e-a}
extra:   #{a-e}
    MSG
  end
end
