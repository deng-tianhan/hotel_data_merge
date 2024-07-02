class DataCleaner
  class << self
    def process(input)
      output = deep_transform(input)

      output.each do |hash|
        hash.transform_keys! do |key|
          key.starts_with?('hotel_') ? key[6..-1] : key
        end
        hash[Hotel::UNIQUE_KEY] ||= hash.delete(Hotel.primary_key)
        hash.merge!(hash.delete(*Hotel::SPECIAL_KEYS) || {})
        hash.compact!
      end

      return output
    end

    def deep_transform(input)
      output = input

      case output
      when String
        output.strip!
      when Array
        output.map! { |x| deep_transform(x) }
      when Hash
        output.transform_keys! { |key| key.to_s.strip.underscore }
        output.transform_values! { |value| deep_transform(value) }
      end

      return output
    end
  end
end