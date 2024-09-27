module Markita
class Base < Sinatra::Base
  set sessions: true
  set bind: OPTIONS.bind || BIND
  set port: OPTIONS.port || PORT
  set server: SERVER
  set server_settings: SERVER_SETTINGS if SERVER_SETTINGS

  def self.run!
    super {SERVER_CONFIG[_1]}
  end

  get PAGE_KEY do |key|
    filepath = File.join ROOT, key+MDX
    raise Sinatra::NotFound unless File.exist? filepath
    Markdown.new(key).filepath filepath
  end

  get SEND_FILE do |path|
    pass unless params.length==1 &&
                (filepath=File.join ROOT, path) &&
                File.exist?(filepath)
    send_file filepath
  end

  get '/' do
    filepath = File.join ROOT, INDEX+MDX
    if File.exist? filepath
      Markdown.new(INDEX).filepath filepath
    else
      redirect '/about.html' unless OPTIONS.no_about
      raise Sinatra::NotFound
    end
  end

  not_found do
    NOT_FOUND
  end
end
end
