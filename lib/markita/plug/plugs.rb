# frozen_string_literal: true

Dir.glob(File.join(Markita::ROOT, 'plug', '*.rb')).each { require it }
