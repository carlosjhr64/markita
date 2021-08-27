module MDServer
  OPTIONS ||= nil

  ROOT = File.expand_path OPTIONS&.root || '~/vimwiki'
  raise "Missing site root directory: "+ROOT  unless File.directory? ROOT

  APPDIR    = File.dirname File.dirname __dir__
  NOT_FOUND = File.read File.join(APPDIR, 'data/not_found.html')
end
