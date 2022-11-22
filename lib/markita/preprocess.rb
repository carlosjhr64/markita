module Markita
class Preprocess
  def initialize(file)
    @file = (file.is_a? String)? StringIO.new(file) : file
    @regx = @template = nil
  end

  def gets
    while line = @file.gets
      case line
      when @regx
        line = @template if @template
        $~.named_captures.each do |name, value|
          line = line.gsub("&#{name.downcase};", value)
          line = line.gsub("&#{name.upcase};", CGI.escape(value))
        end
        return line
      when %r(^! regx = /(.*)/$)
        @regx = Regexp.new $1
      when %r(^! template = "(.*)"$)
        @template = $1+"\n"
      else
        @regx &&= (@template=nil)
        return line
      end
    end
    return nil
  end
end
end
