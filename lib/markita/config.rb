module Markita
  OPTIONS ||= nil

  HEADER_LINKS = ''
  NAVIGATION = ''

  ROOT = File.expand_path OPTIONS&.root || '~/vimwiki'
  raise 'Missing site root directory: '+ROOT unless File.directory? ROOT
  SSL_CERTIFICATE = File.join(ROOT, '.cert.crt')
  SSL_PRIVATE_KEY = File.join(ROOT, '.pkey.pem')
  APPDIR = File.dirname __dir__, 2
  APPDATA = File.join APPDIR, 'data'
  PATH = lambda do |basename|
    [ROOT, APPDATA].map{ File.join _1, basename}.detect{ File.exist? _1}
  end
  NOT_FOUND = File.read PATH['not_found.html']

  EMOJIS = Hash[*File.read(PATH['emojis.tsv']).split(/\s+/)]

  PAGE_KEY  = %r{/(\w[\w/-]*\w)}
  SEND_FILE = %r{/(\w[\w/-]*\w\.\w+)}


  START_TIME = Time.now
end
