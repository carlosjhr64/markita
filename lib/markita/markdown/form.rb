# frozen_string_literal: true

# Markita top level namespace
module Markita
  using Refinement
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    module Form
      field = '(\w+:)?\[(\*)?(\w+)(=("[^"]+")(,"[^"]+")*)?\]'
      RGX = Regexp.new "^!( #{field})+"
      FIELD = Regexp.new field
      POST = /!$/
      ACTION = /\(([^()]*)\)!?$/

      # :reek:LongParameterList :reek:DuplicateMethodCall
      # :reek:TooManyStatements
      # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
      def self.input(type, field, name, values)
        if field
          if values.empty?
            %(  #{field}:<input type="#{type}" name="#{name}">\n)
          elsif values.count > 1
            %(  #{field}:<select name="#{name}">\n).tap do |html|
              values.each do |value|
                html << %(  <option value="#{value}">#{value}</option>\n)
              end
              html << "</select>\n"
            end
          else
            <<-INPUT
  #{field}:<input type="#{type}" name="#{name}"
    value="#{values[0]}">
            INPUT
          end
        elsif name == 'submit'
          %(  <input type="submit" value="#{values[0] || 'Submit'}">\n)
        else
          %(  <input type="hidden" name="#{name}" value="#{values[0]}">\n)
        end
      end

      def self.match?(line) = RGX.match?(line)

      # :reek:LongYieldList :reek:TooManyStatements
      def self.scan(line)
        line.scan(FIELD).each do |field, pwd, name, value|
          field &&= field[0...-1]
          values = value ? value[2...-1].split('","') : []
          type = pwd ? 'password' : 'text'
          yield field, type, name, values
        end
      end

      def self.start(line, attributes)
        method = POST.match?(line) ? ' method="post"' : ''
        action = (mdt = ACTION.match(line)) ? %( action="#{mdt[1]}") : ''
        %(<form#{action}#{method}#{attributes.shift}>\n)
      end

      def self.stop = %(</form>\n)
    end

    PARSERS << :form

    # category: method
    # :reek:TooManyStatements
    def form
      return false unless Form.match?(@line)

      @html << Form.start(@line, @attributes)
      loop do
        Form.scan(@line) do |field, type, name, values|
          @html << Form.input(type, field, name, values)
        end
        break unless Form.match?(@line = @file.gets)

        @html << "  <br>\n"
      end
      @html << Form.stop
      true
    end
    # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity
  end
end
