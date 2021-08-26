module MDServer
  OPTIONS ||= nil
  # Verify options
  ROOT = File.expand_path OPTIONS&.root || '~/vimwiki'
  raise "Missing site root directory: "+ROOT  unless File.directory? ROOT
  VALID_ID = File.exist?(_=File.join(ROOT, '.valid-id')) ?
    File.read(_).strip : nil
  appdir = File.dirname File.dirname __dir__
  FAVICON = File.exist?(_=File.join(ROOT, 'favicon.ico')) ?
    File.read(_) : File.read(File.join(appdir, 'data/favicon.ico'))
  theme = OPTIONS&.theme || 'base16.light'
  HIGHLIGHT = Rouge::Theme.find(theme)&.render(scope: '.highlight')
  raise "Can't find Rouge Theme "+theme unless HIGHLIGHT
  ALLOWED_IPS = (_=OPTIONS&.allowed)? _.split(',') : nil
  if ALLOWED_IPS and not VALID_ID
    raise "Allowed ips without site password does not make sense."
  end
  START_TIME = Time.now
end
