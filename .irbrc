begin
  require File.basename Dir.glob('lib/*.rb')[0]
  klass   = `egrep '^((module)|(class)) \\w+' lib/*.rb | egrep -o '\\w+$'`.strip
  version = eval "#{klass}::VERSION"
  message = "### #{klass} #{version} ###"
rescue Exception
  message = $!.message
end
require 'irbtools/configure'
Irbtools.welcome_message = message
Irbtools.start
### Note ###
# If you get:
#     irb: warn: can't alias ls from irb_ls.
# edit irb/extend-command.rb's install_alias_method print statement to:
#     print "irb: warn: can't alias #{to} from #{from}.\n" if $DEBUG
