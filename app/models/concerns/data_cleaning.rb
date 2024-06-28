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

          next if skip_key?(key)

          # special handling for nested attributes (paperflies format)
          if value.is_a?(Hash)
            output.merge!(data_cleaning(value))
            next
          end

          output[key] = data_cleaning(value)
        end

        output['identifier'] ||= output.delete('id')
      end

      return output
    end

    def self.process_string(input)
      input.strip
    end

    def self.skip_key?(key)
      false
    end
  end
end