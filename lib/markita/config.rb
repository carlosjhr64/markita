# frozen_string_literal: true

# Markita namespace
# :reek:TooManyConstants because it's a configuration file!
module Markita
  HEADER_LINKS = String.new
  NAVIGATION   = String.new

  BIND   = '0.0.0.0'
  PORT   = '8080'
  SERVER = 'webrick'

  MDX = '.md'
  INDEX = 'index'

  ROOT = File.expand_path OPTIONS.root || '~/vimwiki'
  raise "Missing site root directory: #{ROOT}" unless File.directory? ROOT

  SSL_CERTIFICATE = File.join(ROOT, '.cert.crt')
  SSL_PRIVATE_KEY = File.join(ROOT, '.pkey.pem')

  SERVER_SETTINGS =
    if [SSL_CERTIFICATE, SSL_PRIVATE_KEY].all? { File.exist? it }
      {
        SSLEnable:
          true,
        SSLVerifyClient:
          OpenSSL::SSL::VERIFY_NONE,
        SSLCertificate:
          OpenSSL::X509::Certificate.new(File.read(SSL_CERTIFICATE)),
        SSLPrivateKey:
          OpenSSL::PKey::RSA.new(File.read(SSL_PRIVATE_KEY))
      }
    end

  SERVER_CONFIG = lambda do |server|
    puts "#{$PROGRAM_NAME}-#{VERSION}".blue
    puts "Sinatra-#{Sinatra::VERSION} using #{server.class}".blue
  end

  APPDIR  = File.dirname __dir__, 2
  APPDATA = File.join APPDIR, 'data'

  PATH = lambda do |basename|
    [ROOT, APPDATA].map { File.join it, basename }.detect { File.exist? it }
  end

  NOT_FOUND = File.read PATH['not_found.html']

  EMOJIS = Hash[*File.read(PATH['emojis.tsv']).split(/\s+/)]

  PAGE_KEY  = %r{/(\w[\w/-]*\w)} # Note that it starts with a slash
  SEND_FILE = %r{/(\w[\w/-]*\w\.\w+)}

  START_TIME = Time.now
end
