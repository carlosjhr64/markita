# frozen_string_literal: true

require 'net/http'

# Report on Github repositories by a user
module Markita
  # Base class for Sinatra
  class Base
    # Github repositories reports
    # :reek:TooManyInstanceVariables
    # rubocop: disable Metrics, Layout/LineLength
    class GithubRepositories
      def initialize(sort, direction, username)
        @sort = sort
        @direction = direction
        @username = username
        @text = String.new
        @today = Date.today
      end

      # :reek:TooManyStatements
      def intro
        @text << "# Github Repositories\n"

        @text << %(! Username:[username="#{@username}"])
        @text << %([sort="#{@sort}"][direction="#{@direction}"][submit="Go!"])
        @text << "()\n"

        @text << '* Sort [pushed]'
        @text << "(?username=#{@username}&sort=pushed&direction=#{@direction}) "
        @text << 'or [created]'
        @text << "(?username=#{@username}&sort=created&direction=#{@direction})\n"

        @text << '* Direction [ascending]'
        @text << "(?username=#{@username}&sort=#{@sort}&direction=asc) "
        @text << 'or [descending]'
        @text << "(?username=#{@username}&sort=#{@sort}&direction=desc)\n"

        @text << "## Repo #{@username} sorted by #{@sort}(#{@direction}.)\n"
      end

      # :reek:TooManyStatements
      def text
        url = "https://api.github.com/users/#{@username}/repos?per_page=100&"
        repos = JSON.parse Net::HTTP.get(
          URI("#{url}?&sort=#{@sort}&direction=#{@direction}")
        )
        return repos['message'] if repos.is_a?(Hash)

        intro
        repos.each { report(it) }
        @text
      end

      # :reek:DuplicateMethodCall :reek:TooManyStatements
      # :reek:UncommunicativeVariableName
      def report(repo)
        name = repo['name']
        stars = ''
        issues = ''
        n = 0
        n += repo['watchers_count'].to_i
        n += repo['stargazers_count'].to_i
        n += repo['forks'].to_i
        if n.positive?
          n = Math.log(n + 1, 2).round
          stars = " #{':star:' * n}"
        end
        if (n = repo['open_issues'].to_i).positive?
          n = Math.log(n + 1, 2).round
          issues = ':heavy_exclamation_mark:' * n
        end
        @text << "+ [#{name}](#{repo['html_url']})#{stars}#{issues}:\n"
        @text << "+ #{repo['description']}\n"
        @text << "+ #{repo['language']} project created #{Date.parse(repo['created_at'])} "
        date = Date.parse repo['pushed_at']
        if !issues.empty? || @today - date > 365
          @text << "last pushed <mark>#{date}</mark>\n"
        else
          latest = JSON.parse Net::HTTP.get(
            URI("https://api.github.com/repos/#{@username}/#{name}/releases/latest")
          )
          if latest.key?('published_at')
            date = Date.parse latest['published_at']
            @text << if @today - date > 365
                       "last release <mark>#{date}</mark>\n"
                     else
                       "last release #{date}\n"
                     end
          else
            @text << "last pushed #{date}\n"
          end
        end
      end
      # rubocop: enable Metrics, Layout/LineLength
    end

    get '/github_repositories.html' do
      sort = params['sort'] || 'pushed'
      direction = params['direction'] || 'asc'
      # Change the username to yours!
      username = params['username'] || 'carlosjhr64'
      text = GithubRepositories.new(sort, direction, username).text
      Markdown.new('Github Repositories').markdown text
    end
  end
end
