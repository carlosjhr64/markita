require 'nokogiri'

# Export your bookmarks to
#     ~/vimwiki/bookmarks.html
# To view your bookmarks, go to
#     /bookmarks.html
# To search your bookmarks, go to
#     /bookmarks.html?search

module Markita
class Base
  class Bookmarks
    MIN_TOPIC_LENGTH = 4
    SKIP_TOPIC = %w[html http with your]
    KW = /\b\w+\b/
    Bookmark = Struct.new(:href, :title, :tags, :keywords)

    attr_reader :list, :tags, :topics

    def initialize
      @list = []
      traverse!
      @tags = @list.map(&:tags).flatten.uniq.sort
      topics = Hash.new{|h,k| h[k]=0}
      @list.each do |bookmark|
        bookmark.keywords.each do |kw|
          next if (kw.length<MIN_TOPIC_LENGTH) || SKIP_TOPIC.include?(kw)
          topics[kw] += 1
        end
      end
      n = Math.sqrt(@list.length)
      topics.delete_if do |k,v|
        m=Math.sqrt(3.0*[10,k.length-0.5].min)
        v>m*n || v*m<n
      end
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
        keywords = (title+' '+href).scan(KW).map(&:downcase).uniq
        tags = @folders[1..].uniq
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
    search = params['search']&.scan(Bookmarks::KW)&.map(&:downcase)
    topic = params['topic']
    tag = params['tag']
    bookmarks = Bookmarks.new
    text = "# Bookmarks\n"
    text << %(! Search:[search] [submit="Go!"] ()\n)
    text << "Tags:\n"
    bookmarks.tags.each{text << "[#{_1}](?tag=#{_1})\n"}
    text << "\nKeywords:\n"
    bookmarks.topics.each{text << "[#{_1}](?topic=#{_1})\n"}
    seen = Set.new
    sort = ->(a,b){(_=a.tags<=>b.tags).zero? ? a.title<=>b.title : _}
    bookmarks.list.sort{|a,b|sort[a,b]}.each do |bookmark|
      keywords,tags = bookmark.keywords,bookmark.tags
      next unless tag.nil? || tags.include?(tag)
      next unless topic.nil? || keywords.include?(topic)
      next unless search.nil? || search.all?{keywords.include? _1}
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
