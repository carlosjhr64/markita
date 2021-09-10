require 'net/http'
module Markita
class Base
  get '/github_repositories.html' do
    sort = params['sort'] || 'pushed'
    direction = params['direction'] || 'asc'
    username = params['username'] || 'carlosjhr64' # Change the username to yours!
    url = "https://api.github.com/users/#{username}/repos?per_page=100&"
    today = Date.today

    text = "# Github Repositories\n"
    text << "* Sort [pushed](?sort=pushed&direction=#{direction}) or [created](?sort=created&direction=#{direction})\n"
    text << "* Direction [ascending](?sort=#{sort}&direction=asc) or [descending](?sort=#{sort}&direction=desc)\n"
    text << "    {sort: :#{sort}, direction: :#{direction}}\n"
    repos = JSON.parse Net::HTTP.get URI("#{url}?&sort=#{sort}&direction=#{direction}")
    repos.each do |repo|
      text << ": [#{repo['name']}](#{repo['html_url']}):\n"
      text << ": #{repo['description']}\n"
      text << ": #{repo['language']} project created #{Date.parse(repo['created_at'])} "
      date = Date.parse repo['pushed_at']
      if today-date > 365
        text << %Q(last pushed <mark>#{date}</mark>\n)
      else
        text << %Q(last pushed #{date}\n)
      end
    end

    Markdown.new('Github Repositories').markdown text
  end
end
end
