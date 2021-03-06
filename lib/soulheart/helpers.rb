# coding: utf-8
module Soulheart
  module Helpers
    def normalize(str)
      # Letter, Mark, Number, Connector_Punctuation (Chinese, Japanese, etc.)
      str.downcase.gsub(/#{Soulheart.normalizer}/i, '').strip
    end

    def prefixes_for_phrase(phrase)
      words = normalize(phrase).split(' ').reject do |w|
        Soulheart.stop_words.include?(w)
      end
      words.map do |w|
        (0..(w.length - 1)).map { |l| w[0..l] }
      end.flatten.uniq
    end
  end
end
