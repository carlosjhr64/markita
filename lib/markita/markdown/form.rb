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
    end

    PARSERS << :form

    def form
      return false unless (continue = Form::RGX.match(@line))

      fields,nl,submit = 0,false,nil
      action = (_=/\(([^()]*)\)!?$/.match(@line))? %( action="#{_[1]}") : nil
      method = @line.match?(/!$/) ? ' method="post"' : nil
      @html << %(<form#{action}#{method}#{@attributes.shift}>\n)
      while continue
        @html << "  <br>\n" if nl
        @line.scan(Form::FIELD).each do |field, pwd, name, value|
          field &&= field[0...-1]
          value &&= value[2...-1]
          if field
            type = pwd ? 'password' : 'text'
            if value
              if (values = value.split('","')).length > 1
                @html << %(#{field}:<select name="#{name}">\n)
                values.each do |value|
                  fields += 1
                  @html << %(  <option value="#{value}">#{value}</option>\n)
                end
                @html << "</select>\n"
              else
                fields += 1
                @html << %(  #{field}:<input type="#{type}" name="#{name}")
                @html << %( value="#{value}">\n)
              end
            else
              fields += 1
              @html << %(  #{field}:<input type="#{type}" name="#{name}">\n)
            end
          elsif name=='submit'
            submit = value
          else
            @html << %(  <input type="hidden" name="#{name}" value="#{value}">\n)
          end
        end
        continue = Form::RGX.match?(@line = @file.gets) and nl ||= true
      end
      if submit || fields!=1
        submit ||= 'Submit'
        @html << "  <br>\n" if nl
        @html << %(  <input type="submit" value="#{submit}">\n)
      end
      @html << %(</form>\n)
      true
    end
  end
end
