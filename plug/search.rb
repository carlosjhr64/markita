# frozen_string_literal: true

# A simple search for the Markita vimwiki.
module Markita
  # Base class for Sinatra.
  class Base
    # Search isolation module.
    module Search
      # :reek:DuplicateMethodCall :reek:TooManyStatements
      # rubocop:disable Metrics/MethodLength
      def self.matches(keywords)
        section = String.new
        file = nil
        matches = []
        primary = keywords.first
        `egrep -r --include='*.md' -A 2 -B 2 -i '\\b#{primary}\\b' #{ROOT}`
          .each_line do |line|
          if line =~ /^-/
            matches.push [file, section]
            section = String.new
          else
            line.delete_prefix!("#{ROOT}/")
            file, line = line.split(/[:\-]/, 2)
            file.sub!(/\.md$/, '')
            section << line unless line.strip.empty?
          end
        end
        matches.push [file, section] if file
        matches
      end
      # rubocop:enable Metrics/MethodLength
    end

    get '/search.html' do
      text = String.new
      text << "! Search:[keywords] ()\n"
      if (keywords = params['keywords']&.scan(/\w+/)) && !keywords.empty?
        text << "+ Keywords:\n"
        text << "+ #{keywords.join(' ')}\n"
        if (matches = Search.matches(keywords)).empty?
          text << "* No matches for primary keyword: <mark>#{primary}</mark>\n"
        else
          keywords = keywords.map { /\b(#{it})\b/i }
          max = matches.map { |fs| keywords.count { it.match?(fs[1]) } }.max
          matches.each do |file, section|
            next if keywords.count { it.match?(section) } < max

            text << %(<a href="#{file}">#{file}:</a>\n)
            text << "```\n"
            keywords.each do |keyword|
              section = section.gsub(keyword, '<mark>\1</mark>')
            end
            text << section
            text << "```\n"
          end
        end
      end
      Markdown.new('Search').markdown text
    end
  end
end
