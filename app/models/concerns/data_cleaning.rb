require "active_support/concern"

module DataCleaning
  extend ActiveSupport::Concern

  included do
    def self.transform_key(key)
      key = key.to_s.strip.underscore

      # remove prefix (paperflies format)
      key = key[6..-1] if key.starts_with?('hotel_')

      return key
    end

    # deep transform keys and values
    def self.data_cleaning(input)
      output = input

      case input
      when String
        output = process_string(input)
      when Array
        output = input.map { |x| data_cleaning(x) }
      when Hash
        output = {}
        input.each do |key, value|
          key = transform_key(key)

          if value.is_a?(Hash)
            process_nested_hash(key, value, output)
          else
            output[key] = data_cleaning(value)
          end
        end

        output[Hotel::UNIQUE_KEY] ||= output.delete('id')
      end

      return output
    end

    def self.process_string(input)
      input.strip
    end

    def self.process_nested_hash(key, value, output)
    end
  end
end