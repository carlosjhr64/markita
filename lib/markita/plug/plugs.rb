# frozen_string_literal: true

Dir.glob(File.join(Markita::ROOT, 'plug', '*.rb')).each do |path|
  next if Markita.no.include? File.basename(path, '.rb').to_sym

  require path
end
