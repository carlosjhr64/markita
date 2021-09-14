require 'net/http'
module Markita
class Base
  module RubyGems
    def RubyGems.by_username(username)
      gems = JSON.parse Net::HTTP.get URI(
        "https://rubygems.org/api/v1/owners/#{username}/gems.json")
      today = Date.today
      text = "# Ruby gems\n"
      text << %Q(! Username:[username="#{username}"])
      text << %Q([submit="Go!"]()\n)
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
        text << ": [#{name}](?gemname=#{name})#{stars}:\n"
        text << ": #{project['info'].gsub(/\s+/,' ')}\n"
        text << ": Version #{project['version']} created at "
        date = Date.parse project['version_created_at']
        if today-date > 365
          text << "<mark>#{date}</mark>.\n"
        else
          text << "#{date}.\n"
        end
      end
      text
    end

    def RubyGems.about_gem(gemname)
      today = Date.today
      about,used_by,owners=nil,nil,nil
      t1 = Thread.new{
        about = JSON.parse Net::HTTP.get URI(
        "https://rubygems.org/api/v1/gems/#{gemname}.json")
      }
      t2 = Thread.new{
        used_by = JSON.parse Net::HTTP.get URI(
        "https://rubygems.org/api/v1/gems/#{gemname}/reverse_dependencies.json")
      }
      t3 = Thread.new{
        owners = JSON.parse Net::HTTP.get URI(
        "https://rubygems.org/api/v1/gems/#{gemname}/owners.json")
      }
      t1.join; t2.join; t3.join
      text = "# #{gemname} #{about['version']}\n"
      text << about['info'].strip.gsub(/\s+/, ' ')+"\n"
      text << "|:\n"
      text << "* Authors: #{about['authors']}\n"
      text << "* Home: [#{about['homepage_uri']}]\n"
      text << "* Downloads this version: #{about['version_downloads']}\n"
      text << "|\n"
      date = Date.parse about['version_created_at']
      if today-date > 365
        text << "* Date: <mark>#{date}</mark>\n"
      else
        text << "* Date: #{date}\n"
      end
      text << "* Project: [#{about['project_uri']}]\n"
      text << "* Total downloads: #{about['downloads']}\n"
      text << ":|\n"
      text << "## Owners\n"
      owners.each do |owner|
        handle = owner['handle']
        text << "* [#{handle}](?username=#{handle})\n"
      end
      if (dependencies = about['dependencies']['runtime']).length > 0
        text << "## Runtime dependencies\n"
        dependencies.each do |h|
          name = h['name']
          text << "* [#{name}](?gemname=#{name}) `#{h['requirements']}`\n"
        end
      end
      if used_by.length > 0
        text << "## Dependant users\n"
        used_by.sort!{|a,b| a.downcase<=>b.downcase}
        used_by.each do |user|
          text << "[#{user}](?gemname=#{user}) &blacksquare;\n"
        end
      end
      text << "## More...\n"
      about.each do |key, value|
        next if ['name',
                 'downloads',
                 'version',
                 'version_created_at',
                 'version_downloads',
                 'authors',
                 'info',
                 'project_uri',
                 'homepage_uri'].include? key
        text << ": #{key.gsub('_',' ')}:\n"
        if value.is_a? String
          value = value.gsub(/\s+/, ' ')
          value = Date.parse(value).to_s if value.match? /^\d\d\d\d-\d\d-\d\dT/
        end
        value = 'N/A' if value.nil?
        value = value.to_s if value.is_a? Numeric
        if value.is_a? String
          text << ": #{value}\n"
        else
          text << ": `#{value}`\n"
        end
      end
      text
    end
  end

  get '/rubygems.html' do
    if gemname = params['gemname']
      text = RubyGems.about_gem(gemname)
    else
      username = params['username'] || 'carlosjhr64' # Change the username to yours!
      text = RubyGems.by_username(username)
    end
    Markdown.new('Ruby gems').markdown text
  end
end
end
