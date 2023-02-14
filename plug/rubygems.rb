require 'net/http'
module Markita
class Base
  module RubyGems
    def self.by_username(username)
      gems = JSON.parse Net::HTTP.get URI(
        "https://rubygems.org/api/v1/owners/#{username}/gems.json")
      today = Date.today
      text = "# Ruby gems\n"
      text << %(! Username:[username="#{username}"])
      text << %([submit="Go!"]()\n)
      text << "## Gems by #{username}\n"
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
        name = project['name']
        text << "+ [#{name}](?gemname=#{name})#{stars}:\n"
        text << "+ #{project['info'].gsub(/\s+/,' ').gsub(':','&#58;')}\n"
        text << "+ Version #{project['version']} created at "
        date = Date.parse project['version_created_at']
        text << today-date>365 ? "<mark>#{date}</mark>.\n" : "#{date}.\n"
      end
      text
    end

    def self.about_gem(gemname)
      today = Date.today
      about,used_by,owners=nil,nil,nil
      t1 = Thread.new do
        about = JSON.parse Net::HTTP.get URI(
          "https://rubygems.org/api/v1/gems/#{gemname}.json")
      end
      t2 = Thread.new do
        used_by = JSON.parse Net::HTTP.get URI(
          'https://rubygems.org/api/v1/gems/' \
          "#{gemname}/reverse_dependencies.json")
      end
      t3 = Thread.new do
        owners = JSON.parse Net::HTTP.get URI(
          "https://rubygems.org/api/v1/gems/#{gemname}/owners.json")
      end
      t1.join; t2.join; t3.join
      text = "# #{gemname} #{about['version']}\n"
      text << about['info'].strip.gsub(/\s+/, ' ')+"\n"
      text << "|:\n"
      text << "* Authors: #{about['authors']}\n"
      text << "* Home: #{about['homepage_uri']}\n"
      text << "* Downloads this version: #{about['version_downloads']}\n"
      text << "|\n"
      date = Date.parse about['version_created_at']
      text << today-date>365 ? "* Date: <mark>#{date}</mark>\n" :
                               "* Date: #{date}\n"
      text << "* Project: #{about['project_uri']}\n"
      text << "* Total downloads: #{about['downloads']}\n"
      text << ":|\n"
      text << "## Owners\n"
      owners.each do |owner|
        handle = owner['handle']
        text << "* [#{handle}](?username=#{handle})\n"
      end
      unless (dependencies=about['dependencies']['runtime']).empty?
        text << "## Runtime dependencies\n"
        dependencies.each do |h|
          name = h['name']
          text << "* [#{name}](?gemname=#{name}) `#{h['requirements']}`\n"
        end
      end
      unless used_by.empty?
        text << "## Dependant users\n"
        used_by.sort!{|a,b| a.downcase<=>b.downcase}
        used_by.each do |user|
          text << "[#{user}](?gemname=#{user}) &blacksquare;\n"
        end
      end
      text << "## More...\n"
      about.each do |key, value|
        next if %w[name downloads version version_created_at version_downloads
                   authors info project_uri homepage_uri].include? key
        text << "+ #{key.gsub('_',' ')}:\n"
        if value.is_a? String
          value = value.gsub(/\s+/, ' ')
          value = Date.parse(value).to_s if value.match? /^\d\d\d\d-\d\d-\d\dT/
        end
        value = 'N/A' if value.nil?
        value = value.to_s if value.is_a? Numeric
        text << value.is_a?(String)? "+ #{value}\n": "+ `#{value}`\n"
      end
      text
    end
  end

  get '/rubygems.html' do
    if (gemname=params['gemname'])
      text = RubyGems.about_gem(gemname)
    else
      # Change the username to yours!
      username = params['username'] || 'carlosjhr64'
      text = RubyGems.by_username(username)
    end
    Markdown.new('Ruby gems').markdown text
  end
end
end
