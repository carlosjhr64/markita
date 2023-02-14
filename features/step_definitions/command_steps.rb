Given %r{Given command "([^"]*)"} do |command|
  @command = command
end

Given %r{Given options? "([^"]*)"} do |options|
  @options = options
end

When %r{When we run command} do
  @stdout, @stderr, @status = Open3.capture3("#{@command} #{@options}")
  [@stdout, @stderr].each(&:chomp!)
end

Then %r{Then exit status is "(\d+)"} do |status|
  unless @status.exitstatus == status.to_i
    raise "Got #{@status} instead of #{status}"
  end
end

Then %r{Then stdout is '([^']*)'} do |string|
  unless @stdout == string
    raise "stdout: Expectected '#{string}'. Got '#{@stdout}'"
  end
end

Then %r{Then stdout is ("[^"]*")} do |string|
  unless @stdout.inspect == string
    raise "stdout: Expectected '#{string}'. Got '#{@stdout}'"
  end
end

Then %r{Then stderr is "([^"]*)"} do |string|
  unless @stderr == string
    raise "stderr: Expectected '#{string}'. Got '#{@stderr}'"
  end
end

Then %r{Then stderr is '([^']*)'} do |string|
  unless @stderr == string
    raise "stderr: Expectected '#{string}'. Got '#{@stderr}'"
  end
end

Then %r{Then stdout includes "([^"]*)"} do |string|
  unless @stdout.include?(string)
    raise "Stdout did not include '#{string}'"
  end
end

Then %r{Then stderr includes "([^"]*)"} do |string|
  unless @stderr.include?(string)
    raise "Stderr did not include '#{string}'"
  end
end

Then %r{Then stdout matches /([^/]*)/} do |string|
  unless Regexp.new(string).match?(@stdout)
    raise "Stdout did not match '#{string}'"
  end
end

Then %r{Then (\w+) => (\S+)} do |k,v|
  h = JSON.parse @stdout
  unless h[k]==v
    raise "#{k} is not #{v}, it's #{h[k]}"
  end
end

Then %r{Then (\w+) maps to true} do |k|
  h = JSON.parse @stdout
  unless h[k]==true
    raise "#{k} is not true, it's #{h[k]}"
  end
end

Then %r{Then (\w+) maps to nil} do |k|
  h = JSON.parse @stdout
  unless h[k].nil?
    raise "#{k} is not nil, it's #{h[k]}"
  end
end

Then %r{Then (\w+) is \[(\S+)\]} do |k,v|
  h = JSON.parse @stdout
  l = h[k].join(',')
  unless l==v
    raise "#{k} is not #{v}, it's #{l}"
  end
end

Then %r{Then header is "(.*)"} do |v|
  header = @stdout.split("\n",2).first
  unless header==v
    raise "Header is not #{v}, it's #{header}"
  end
end

Then %r{Then digest is "(.*)"} do |v|
  # This is just to ensure not changes to the output occured in future edits...
  # Note that stdout was striped, so adding the newline back in,
  # making the use of piped md5sum output possible.
  digest = Digest::MD5.hexdigest(@stdout + "\n")
  unless digest==v
    raise "Digest is not #{v}, it's #{digest}"
  end
end
