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

      def self.input_select(field, name, values)
        %(  #{field}:<select name="#{name}">\n).tap do |html|
          values.each do |value|
            html << %(    <option value="#{value}">#{value}</option>\n)
          end
          html << "  </select>\n"
        end
      end

      def self.input_text(field, type, name)
        %(  #{field}:<input type="#{type}" name="#{name}">\n)
      end

      # :reek:LongParameterList :reek:TooManyStatements
      def self.input(type, field, name, values)
        if field
          if values.empty? then input_text(field, type, name)
          elsif values.count > 1 then input_select(field, name, values)
          else
            input_defaulted(field, type, name, values)
          end
        elsif name == 'submit' then input_submit(values)
        else
          input_hidden(name, values)
        end
      end

      def self.input_submit(values)
        %(  <input type="submit" value="#{values[0] || 'Submit'}">\n)
      end

      def self.input_hidden(name, values)
        %(  <input type="hidden" name="#{name}" value="#{values[0]}">\n)
      end

      # :reek:LongParameterList
      def self.input_defaulted(field, type, name, values)
        <<-INPUT
  #{field}:<input type="#{type}" name="#{name}"
    value="#{values[0]}">
        INPUT
      end

      def self.match?(line) = RGX.match?(line)

      # :reek:ControlParameter :reek:NilCheck :reek:LongParameterList
      def self.maybe(yon, name, field, values)
        return :NO if yon == :NO || (field.nil? && name == 'submit')
        return yon unless field && values.count < 2

        yon == :yes ? :no : :YES
      end

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

      # :reek:ControlParameter
      def self.submit(yon)
        case yon
        when :yes
          %(  <input type="submit">\n)
        when :YES
          %(  <br>\n  <input type="submit">\n)
        else
          ''
        end
      end
    end

    PARSERS << :form

    # category: method
    # :reek:TooManyStatements
    # rubocop:disable Metrics/MethodLength
    def form
      return false unless Form.match?(@line)

      yon = :yes # Append submit button?
      @html << Form.start(@line, @attributes)
      loop do
        Form.scan(@line) do |field, type, name, values|
          yon = Form.maybe(yon, name, field, values)
          @html << Form.input(type, field, name, values)
        end
        break unless Form.match?(@line = @file.gets)

        @html << "  <br>\n"
      end
      @html << Form.submit(yon)
      @html << Form.stop
      true
    end
    # rubocop:enable Metrics/MethodLength
  end
end
