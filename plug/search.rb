module Markita
class Base
  get '/search.html' do
    text = "! Search:[keywords] ()\n"
    if (keywords=params['keywords']&.scan(/\w+/)) && !keywords.empty?
      text << "+ Keywords:\n"
      text << "+ #{keywords.join(' ')}\n"

      section,file,matches = '','',[]
      primary = keywords.max_by(&:length)
      `egrep -r --include='*.md' -A 1 -B 1 -i '\\b#{primary}\\b' #{ROOT}`
      .each_line do |line|
        if line=~/^-/
          matches.push [file, section]
          section = ''
        else
          line.sub!(ROOT+'/','')
          file,line = line.split(/[:\-]/,2)
          file.sub!(/\.md$/,'')
          section << line unless line.strip.empty?
        end
      end
      matches.push [file, section]

      keywords = keywords.map{/\b(#{_1})\b/i}
      max = matches.map{|fs| keywords.count{_1.match?(fs[1])}}.max

      matches.each do |file, section|
        next if keywords.count{_1.match?(section)} < max
        text << %(<a href="#{file}">#{file}:</a>\n)
        text << "```\n"
        keywords.each do |keyword|
          section = section.gsub(keyword, '<mark>\1</mark>')
        end
        text << section
        text << "```\n"
      end
    end
    Markdown.new('Search').markdown text
  end
end
end
