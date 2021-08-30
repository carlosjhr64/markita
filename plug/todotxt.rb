module Markita
class Base
  get '/todotxt.html' do
    text = "# [Todo.txt](https://todotxt.org)\n"
    # Get tasks
    tasks = `todo.sh -p list`.lines.select{/^\d\d /.match?_1}.map{_1.strip}
    # Get projects
    projects = Hash.new{|h,k|h[k]=[]}
    tasks.each do |task|
      if /\+\w+/=~task
        task.scan(/\+(\w+)/){|m| projects[m[0]].push task}
      else
        projects['* Unspecified *'].push task
      end
    end
    # Get contexts
    contexts = Hash.new{|h,k|h[k]=[]}
    tasks.each do |task|
      if /\@\w+/=~task
        task.scan(/\@(\w+)/){|m| contexts[m[0]].push task}
      else
        contexts['* Unspecified *'].push task
      end
    end
    text << %Q(\n!-- <table><tr><td style="vertical-align:top;padding:15px"> --\n)
    # Puts projects
    text << "\n## Projects\n"
    projects.each do |project, tasks|
      text << "\n### #{project}\n"
      tasks.each do |task|
        task = task.dup
        task.sub!(/^\d+\s*/, '')
        task.sub!(/\s*\([A-Z]\)/, '')
        task.gsub!(/\s*\+\w+/, '')
        task.gsub!(/\@(\w+)/, '<small>\\1</small>')
        text << '- ' << task << "\n"
      end
    end
    text << %Q(\n!-- </td><td style="vertical-align:top;padding:15px"> --\n)
    text << "\n## Contexts\n"
    # Puts contexts
    contexts.each do |context, tasks|
      text << "\n### #{context}\n"
      tasks.each do |task|
        task = task.dup
        task.sub!(/^\d+\s*/, '')
        task.strip!
        task.sub!(/\s*\([A-Z]\)/, '')
        task.gsub!(/\s*\@\w+/, '')
        task.gsub!(/\+(\w+)/, '<small>\\1</small>')
        text << '* ' << task << "\n"
      end
    end
    text << "\n!-- </td></tr></table> --\n"
    text << "\n"
    text << <<~VERSION
      ~~~
      #{`todo.sh -V`.strip}
      ~~~ 
    VERSION
    Base.page('Todo.txt'){ Base.process markdown text }
  end
end
end
