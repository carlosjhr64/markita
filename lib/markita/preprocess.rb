module Markita
class Preprocess
  def initialize(file)
    @file = (file.is_a? String)? StringIO.new(file) : file
    @regx = @template = nil
  end

  def gets
    if line = @file.gets
      case line
      when @regx
        line = @template if @template
        $~.named_captures.each do |name, value|
          line = line.gsub("&#{name.downcase};", value)
          line = line.gsub("&#{name.upcase};", CGI.escape(value))
        end
      when %r(^! regx = /(.*)/$)
        @regx = Regexp.new $1
        line = gets
      when %r(^! template = "(.*)"$)
        @template = $1+"\n"
        line = gets
      else
        @regx &&= (@template=nil)
      end
    end
    line
  end
end
end
