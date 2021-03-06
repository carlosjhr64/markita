module Markita
  OPTIONS ||= nil

  HEADER_LINKS = ''
  NAVIGATION = ''

  ROOT = File.expand_path OPTIONS&.root || '~/vimwiki'
  raise "Missing site root directory: "+ROOT  unless File.directory? ROOT
  APPDATA = File.join File.dirname(File.dirname __dir__), 'data'
  PATH = lambda do |basename|
    [ROOT, APPDATA].map{ File.join _1, basename}.detect{ File.exist? _1}
  end
  NOT_FOUND = File.read PATH['not_found.html']

  EMOJIS = Hash[*File.read(PATH['emojis.tsv']).split(/\s+/)]

  PAGE_KEY   = %r{/(\w[\w\/\-]*\w)}
  IMAGE_PATH = %r{/(\w[\w\/\-]*\w\.((png)|(gif)))}

  START_TIME = Time.now
end
