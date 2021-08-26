module MDServer
  OPTIONS ||= nil
  # Verify options
  ROOT = File.expand_path OPTIONS&.root || '~/vimwiki'
  raise "Missing site root directory: "+ROOT  unless File.directory? ROOT
  ['favicon.ico', '.cert.crt', '.pkey.pem', '.valid-id'].each do |basename|
    filename = File.join ROOT, basename
    raise "Missing #{filename}" unless File.file? filename
  end
  VALID_ID = File.read(File.join ROOT, '.valid-id').strip
  FAVICON = File.read(File.join ROOT, 'favicon.ico')
  theme = OPTIONS&.theme || 'base16.light'
  HIGHLIGHT = Rouge::Theme.find(theme)&.render(scope: '.highlight')
  raise "Can't find Rouge Theme "+theme unless HIGHLIGHT
  ALLOWED_IPS = (OPTIONS&.allowed || '127.0.0.1').split(',')
  START_TIME = Time.now
end
