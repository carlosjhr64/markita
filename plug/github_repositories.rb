require 'net/http'
module Markita
class Base
  get '/github_repositories.html' do
    sort = params['sort'] || 'pushed'
    direction = params['direction'] || 'asc'
    # Change the username to yours!
    username = params['username'] || 'carlosjhr64'
    url = "https://api.github.com/users/#{username}/repos?per_page=100&"
    today = Date.today

    text = "# Github Repositories\n"

    text << %(! Username:[username="#{username}"])
    text << %([sort="#{sort}"][direction="#{direction}"][submit="Go!"])
    text << "()\n"

    text << '* Sort [pushed]'
    text << "(?username=#{username}&sort=pushed&direction=#{direction}) "
    text << 'or [created]'
    text << "(?username=#{username}&sort=created&direction=#{direction})\n"

    text << '* Direction [ascending]'
    text << "(?username=#{username}&sort=#{sort}&direction=asc) "
    text << 'or [descending]'
    text << "(?username=#{username}&sort=#{sort}&direction=desc)\n"

    text << "## Repo #{username} sorted by #{sort}(#{direction}.)\n"

    repos = JSON.parse Net::HTTP.get(
      URI "#{url}?&sort=#{sort}&direction=#{direction}")
    repos.each do |repo|
      stars,issues = '',''
      if (n=repo['watchers'].to_i).positive?
        n = Math.log(n+1, 2).round
        stars = ' ' + ':star:'*n
      end
      if (n=repo['open_issues'].to_i).positive?
        n = Math.log(n+1, 2).round
        issues = ':heavy_exclamation_mark:'*n
      end
      text << "+ [#{repo['name']}](#{repo['html_url']})#{stars}#{issues}:\n"
      text << "+ #{repo['description']}\n"
      text << "+ #{repo['language']} project created " \
              "#{Date.parse(repo['created_at'])} "
      date = Date.parse repo['pushed_at']
      text << (today-date>365 || !issues.empty? ? %(last pushed <mark>#{date}</mark>\n) :
                               %(last pushed #{date}\n))
    end

    Markdown.new('Github Repositories').markdown text
  end
end
end
