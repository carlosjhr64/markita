# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Table
      RGX = /^\|.+\|$/
    end

    @@parsers << :table

    # :reek:DuplicateMethodCall :reek:TooManyStatements
    # :reek:UncommunicativeVariableName
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength, Layout/LineLength
    def table
      return false unless Table::RGX.match? @line

      @html << "<table#{@attributes.shift}>\n"
      @html << "<thead#{@attributes.shift}><tr><th>"
      @html << @line[1...-1].split('|').map { inline(it.strip) }.join('</th><th>')
      @html << "</th></tr></thead>\n"
      align = []
      while (@line = @file.gets)&.match? Table::RGX
        @html << '<tr>'
        @line[1...-1].split('|').each_with_index do |cell, i|
          case cell
          when /^\s*:-+:\s*$/
            align[i] = ' align="center"'
            @html << '<td><hr></td>'
          when /^\s*-+:\s*$/
            align[i] = ' align="right"'
            @html << '<td><hr></td>'
          when /^\s*:-+\s*$/
            align[i] = ' align="left"'
            @html << '<td><hr></td>'
          else
            @html << "<td#{align[i]}>#{inline(cell.strip)}</td>"
          end
        end
        @html << "</tr>\n"
      end
      @html << "</table>\n"
      true
    end
    # rubocop:enable Metrics/MethodLength, Layout/LineLength
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  end
end
