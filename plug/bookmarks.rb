require 'nokogiri'
require 'set'

# NOTE: Export your bookmarks to
#     ~/vimwiki/bookmarks.html
module Markita
class Base
  class Bookmarks
    KW = /\w\w+/
    attr_reader :titles, :tags, :taggers, :keywords, :topics
    def initialize
      @doc      = Nokogiri::HTML File.read File.join(ROOT, 'bookmarks.html')
      @titles   = Hash.new{|h,k| h[k]=Set.new}
      @tags     = Hash.new{|h,k| h[k]=Set.new}
      @keywords = Hash.new{|h,k| h[k]=Set.new}
      @folders  = []
      traverse!
      # Don't need to carry these around anymore:
      @doc = @folders = nil
      topics = Hash.new{|h,k| h[k]=0}
      @keywords.each do |href, keywords|
        keywords.each do |kw|
          topics[kw] += 1
        end
      end
      n = Math.sqrt(@keywords.length)
      max = n*5.0
      min = n/5.0
      topics.delete_if{|k,v|v>max or v<min}
      @topics = topics.keys.sort
      @taggers = @tags.values.map{|s|s.to_a}.flatten.uniq.sort
    end
    def traverse!
      @doc.xpath('./html/body/dl').each do |shoot|
        traverse(shoot)
      end
    end
    def traverse(branch)
      name = branch.name
      case name
      when 'h3'
        @folders.push branch.text
      when 'dl', 'dt'
        branch.xpath('./*').each do |shoot|
          traverse(shoot)
        end
        @folders.pop if name == 'dl'
      when 'a'
        href = branch['href']
        titles,tags,keywords = @titles[href],@tags[href],@keywords[href]
        @folders[1..-1].each{|folder| tags.add folder}
        title = branch.text
        titles.add(title.empty? ? href : title)
        title.scan(KW){|kw| keywords.add kw.downcase}
        href.scan(KW){|kw| keywords.add kw.downcase}
      end
    end
  end

  get '/bookmarks.html' do
    search = params['search']&.scan(Bookmarks::KW)&.map{|kw| kw.downcase}
    topic = params['topic']
    tag = params['tag']
    bookmarks = Bookmarks.new
    text = "# Bookmarks\n"
    text << %Q(! Search:[search] [submit="Go!"] ()\n)
    text << "Tags:\n"
    bookmarks.taggers.each do |tagger|
      text << "[#{tagger}](?tag=#{tagger})\n"
    end
    text << "\nKeywords:\n"
    bookmarks.topics.each do |topic|
      text << "[#{topic}](?topic=#{topic})\n"
    end
    seen = Set.new
    bookmarks.tags.sort{|a,b|a[1].to_a<=>b[1].to_a}.each do |href, tags|
      next unless tag.nil? or tags.include? tag
      keywords = bookmarks.keywords[href]
      next unless topic.nil? or keywords.include? topic
      next unless search.nil? or search.all?{|kw| keywords.include? kw}
      unless seen.include? tags
        seen.add tags
        text << "# #{tags.to_a.join('/')}\n"
      end
      bookmarks.titles[href].each do |title|
        title = title.gsub('[', '&#91;').gsub(']', '&#93;')
        text << "* [#{title}](#{href})\n"
      end
    end
    Markdown.new('Bookmarks').markdown text
  end
end
end
