# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    # :reek:TooManyConstants
    module Inline
      # category: details

      # When the writer does not mean to invoke a substitutions caused by a
      # special character, that character can be escaped with a backslash.
      # This is then replaced with its HTML entity.
      ENTITY = /\\([<>*"~`_&;:\\])/
      def self.entity(mdt) = "&##{mdt[1].ord};"

      FOOTNOTE = /\[\^(\d+)\](:)?/
      # :reek:ControlParameter
      def self.footnote(mdt = nil, num: mdt[1], ref: mdt[2])
        if ref
          %(<a id="fn:#{num}" href="#fnref:#{num}">#{num}:</a>)
        else
          %(<a id="fnref:#{num}" href="#fn:#{num}"><sup>#{num}</sup></a>)
        end
      end

      SUBSCRIPT = /\\\(([^()]+)\)/
      def self.subscript(mdt) = "<sub>#{mdt[1]}</sub>"

      SUPERSCRIPT = /\\\^\(([^()]+)\)/
      def self.superscript(mdt) = "<sup>#{mdt[1]}</sup>"

      URL = %r{(https?://[\w./&+?%-]+)}
      def self.url(mdt, hrf = mdt[1]) = %(<a href="#{hrf}">#{hrf}</a>)

      BOLD = /\*([^*]+)\*/
      def self.bold(mdt) = "<b>#{mdt[1]}</b>"

      CODE = /`([^`]+)`/
      def self.code(mdt) = "<code>#{mdt[1].gsub('<', '&lt;')}</code>"

      EMOJI = /:(\w+):/
      EMOJIS = Hash[*File.read(PATH['emojis.tsv']).split(/\s+/)]
      def self.emoji(mdt) = (emj = EMOJIS[mdt[1]]) ? "&#x#{emj};" : mdt[0]

      ITALIC = /"([^"]+)"/
      def self.italic(mdt) = "<i>#{mdt[1]}</i>"

      STRIKE = /~([^~]+)~/
      def self.strike(mdt) = "<s>#{mdt[1]}</s>"

      UNDERLINE = /_([^_]+)_/
      def self.underline(mdt) = "<u>#{mdt[1]}</u>"

      ANCHOR = /\[([^\[\]]+)\]\(([^(")]+)\)/
      def self.anchor(mdt)
        href, title = mdt[2].split(/\s+/, 2).map(&:strip)
        title = %( title="#{title}") if title
        text = tag(mdt[1], EMOJI, method(:emoji))
        %(<a href="#{href}"#{title}>#{text}</a>)
      end

      # category: algorithm

      # :reek:DuplicateMethodCall :reek:TooManyStatements
      # rubocop:disable Metrics/MethodLength
      def self.tag(entry, regx, m2string, &block)
        if (mdt = regx.match entry)
          string = String.new
          while mdt
            pre_match = (block ? block.call(mdt.pre_match) : mdt.pre_match)
            string << (pre_match + m2string[mdt])
            post_match = mdt.post_match
            mdt = regx.match(post_match)
          end
          string << (block ? block.call(post_match) : post_match)
          return string
        end
        block ? block.call(entry) : entry
      end

      # :reek:NestedIterators :reek:TooManyStatements
      # :reek:UncommunicativeVariableName
      # rubocop:disable Metrics/AbcSize
      def self.tags(line)
        line = tag(line, ENTITY, method(:entity))
        line = tag(line, CODE, method(:code)) do |string|
          tag(string, ANCHOR, method(:anchor)) do |str|
            tag(str, URL, method(:url)) do |s|
              s = tag(s, EMOJI,       method(:emoji))
              s = tag(s, BOLD,        method(:bold))
              s = tag(s, ITALIC,      method(:italic))
              s = tag(s, STRIKE,      method(:strike))
              s = tag(s, UNDERLINE,   method(:underline))
              s = tag(s, FOOTNOTE,    method(:footnote))
              s = tag(s, SUPERSCRIPT, method(:superscript))
              tag(s, SUBSCRIPT, method(:subscript))
            end
          end
        end
        line.sub(/ ?[ \\]$/, '<br>')
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end

    # category: method

    def inline(line)
      line = Inline.tags(line)
      Inline.tag(line, /<a href="(\d+)">/, lambda do |mdt|
        key = mdt[1]
        %(<a href="#{@metadata[key] || key}">)
      end)
    end
  end
end
