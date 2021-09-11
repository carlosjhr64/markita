require 'nokogiri'
require 'set'

# NOTE: Export your bookmarks to
#     ~/vimwiki/bookmarks.html
module Markita
class Base
  class Bookmarks
    KW = /\w\w+/
    Bookmark = Struct.new(:href, :title, :tags, :keywords)

    attr_reader :list, :tags, :topics
    def initialize
      @list = []
      traverse!
      @tags = @list.map{_1.tags}.flatten.uniq.sort
      topics = Hash.new{|h,k| h[k]=0}
      @list.each do |bookmark|
        bookmark.keywords.each do |kw|
          topics[kw] += 1
        end
      end
      n = Math.sqrt(@list.length)
      max = n*5.0 # How about by word length?
      min = n/5.0
      topics.delete_if{|k,v|v>max or v<min}
      @topics = topics.keys.sort{|a,b|topics[b]<=>topics[a]}
    end

    def traverse!
      @doc = Nokogiri::HTML File.read File.join(ROOT, 'bookmarks.html')
      @folders = []
      @doc.xpath('./html/body/dl').each do |shoot|
        traverse(shoot)
      end
      # Don't need to carry these around anymore:
      @doc = @folders = nil
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
        href,title = branch['href'],branch.text
        keywords = (title+' '+href).scan(KW).map{|kw| kw.downcase}.uniq
        tags = @folders[1..-1].uniq
        bookmark = Bookmark.new
        bookmark.href = href
        bookmark.title = title.empty? ? href : title
        bookmark.tags = tags
        bookmark.keywords = keywords
        @list.push bookmark
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
    bookmarks.tags.each{text << "[#{_1}](?tag=#{_1})\n"}
    text << "\nKeywords:\n"
    bookmarks.topics.each{text << "[#{_1}](?topic=#{_1})\n"}
    seen = Set.new
    sort = lambda {|a,b| (_=a.tags<=>b.tags)==0 ? a.title<=>b.title : _}
    bookmarks.list.sort{sort[_1,_2]}.each do |bookmark|
      keywords,tags = bookmark.keywords,bookmark.tags
      next unless tag.nil? or tags.include? tag
      next unless topic.nil? or keywords.include? topic
      next unless search.nil? or search.all?{keywords.include? _1}
      unless seen.include? tags
        seen.add tags
        text << "# #{tags.to_a.join('/')}\n"
      end
      title = bookmark.title.gsub('[', '&#91;').gsub(']', '&#93;')
      href = bookmark.href
      text << "* [#{title}](#{href})\n"
    end
    Markdown.new('Bookmarks').markdown text
  end
end
end
