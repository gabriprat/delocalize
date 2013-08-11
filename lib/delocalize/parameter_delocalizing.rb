module Delocalize
  module ParameterDelocalizing
    def delocalize(options)
      self.class.new(delocalize_hash(self, options))
    end

  private

    def delocalize_hash(hash, options, key_stack = [])
      hash.each do |key, value|
        hash[key] = value.is_a?(Hash) ? delocalize_hash(hash[key], options, [*key_stack, key]) : delocalize_parse(options, [*key_stack, key], value)
      end
    end

    def delocalize_parse(options, key_stack, value)
      parser = delocalize_parser_for(options, key_stack)
      parser ? parser.parse(value) : value
    end

    def delocalize_parser_for(options, key_stack)
      parser_type = key_stack.reduce(options) { |h, key| h.stringify_keys[key.to_s] }
      return unless parser_type

      parser_name = "delocalize_#{parser_type}_parser"
      respond_to?(parser_name, true) ? send(parser_name) : raise(Delocalize::ParserNotFound.new("Unknown parser: #{parser_type}"))
    end

    def delocalize_number_parser
      @delocalize_number_parser ||= NumberParser.new
    end

    def delocalize_time_parser
      @delocalize_time_parser ||= DateTimeParser.new(Time)
    end

    def delocalize_date_parser
      @delocalize_date_parser ||= DateTimeParser.new(Date)
    end

  end
end