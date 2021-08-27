module MDServer
  OPTIONS ||= nil

  ROOT = File.expand_path OPTIONS&.root || '~/vimwiki'
  raise "Missing site root directory: "+ROOT  unless File.directory? ROOT

  APPDIR    = File.dirname File.dirname __dir__
  NOT_FOUND = File.read File.join(APPDIR, 'data/not_found.html')
  FAVICON   = File.exist?(_=File.join(ROOT, 'favicon.ico')) ?
              File.read(_) :
              File.read(File.join(APPDIR, 'data/favicon.ico'))

  theme = OPTIONS&.theme || 'base16.light'
  HIGHLIGHT = Rouge::Theme.find(theme)&.render(scope: '.highlight')
  raise "Can't find Rouge Theme "+theme unless HIGHLIGHT

  START_TIME = Time.now
end
