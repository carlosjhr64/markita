require 'net/http'
module Markita
class Base
  get '/rubygems.html' do
    username = params['username'] || 'carlosjhr64' # Change the username to yours!
    url = "https://rubygems.org/api/v1/owners/#{username}/gems.json"
    today = Date.today

    text = "# Ruby gems\n"

    text << %Q(! Username:[username="#{username}"])
    text << %Q([submit="Go!"]()\n)

    text << "## Gems by #{username}\n"

    gems = JSON.parse Net::HTTP.get URI(url)
    gems.sort!{|a,b| b['version_downloads']<=>a['version_downloads']}
    gems.each do |project|
      stars = ''
      m,n = project['downloads'].to_i,project['version_downloads'].to_i
      m -= n
      if m > 100
        m = Math.log(m, 100).round
        stars << ' ' if stars.empty?
        stars << ':star2:'*m
      end
      if n > 100
        n = Math.log(n, 100).round
        stars << ' ' if stars.empty?
        stars << ':star:'*n
      end
      text << ": [#{project['name']}](#{project['project_uri']})#{stars}:\n"
      text << ": #{project['info'].gsub(/\s+/,' ')}\n"
      text << ": Version #{project['version']} created at "
      date = Date.parse project['version_created_at']
      if today-date > 365
        text << "<mark>#{date}</mark>.\n"
      else
        text << "#{date}.\n"
      end
    end

    Markdown.new('Ruby gems').markdown text
  end
end
end
