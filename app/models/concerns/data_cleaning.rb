require "active_support/concern"

module DataCleaning
  extend ActiveSupport::Concern

  included do
    def self.transform_key(key)
      key.to_s.strip.underscore
    end

    def self.data_cleaning(input)
      deep_transform(input)
    end

    def self.deep_transform(input)
      output = input

      case input
      when String
        output = process_string(input)
      when Array
        output = input.map { |x| deep_transform(x) }
      when Hash
        output = {}
        input.each do |key, value|
          key = transform_key(key)

          if value.is_a?(Hash)
            process_nested_hash(key, value, output)
          else
            output[key] = deep_transform(value)
          end
        end
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