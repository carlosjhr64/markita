module Markita
class Base
  # Uses todo.sh to get task list
  # Interprets the following keys:
  #   due:YYYY-MM-DD    Due date
  #   last:YYYY-MM-DD   Last done date
  #   every:N           Due date is N days after last done
  #   every:Weekday     Due date is on the given Weekday after last done
  module TodoTXT
    def TodoTXT.decorate(task, tag=nil)
      task = task.dup
      task.sub!  tag,           ''  if tag
      task.sub!  /^\d+/,        ''
      task.sub!  /\([A-Z]\)/,   ''
      task.gsub! /([\@\+]\w+)/, '<small>\\1</small>'
      task.gsub! /(\w+:\S+)/,   '<small>\\1</small>'
      task.gsub! /\s+/,         ' '
      task.strip!
      task
    end
  end

  get '/todotxt.html' do
    text = "# [Todo.txt](https://todotxt.org)\n"
    # Get tasks
    tasks = `todo.sh -p list`.lines.select{/^\d+ /.match?_1}.map{_1.strip}
    # Get projects and contexts
    today,due,projects,contexts = Date.today,[],Hash.new{|h,k|h[k]=[]},Hash.new{|h,k|h[k]=[]}
    tasks.each do |task|
      if /\+\w+/.match? task
        task.scan(/\+(\w+)/){|m| projects[m[0]].push task}
      else
        projects['* Unspecified *'].push task
      end
      if /\@\w+/.match? task
        task.scan(/\@(\w+)/){|m| contexts[m[0]].push task}
      else
        contexts['* Unspecified *'].push task
      end
      if / due:(?<date>\d\d\d\d-\d\d-\d\d)\b/=~task
        due.push task if today >= Date.parse(date)
      end
      if / last:(?<date>\d\d\d\d-\d\d-\d\d)\b/=~task
        if / every:(?<n>\d+)\b/=~task
          due.push task if today >= Date.parse(date)+n.to_i
        elsif / every:(?<w>[SMTWF]\w+)\b/=~task
          if w==['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'][today.wday]
            due.push task if today > Date.parse(date)
          end
        end
      end
      due.uniq!
    end
    unless due.empty?
      text << "\n## Due\n"
      due.each do |task|
        text << "* #{TodoTXT.decorate(task)}\n"
      end
    end
    text << %Q(\n!-- <table><tr><td style="vertical-align:top;padding:15px"> --\n)
    # Puts projects
    text << "\n## Projects\n"
    projects.each do |project, tasks|
      text << "\n### #{project}\n"
      tag = Regexp.new '[+]'+project+'\b'
      tasks.each do |task|
        text << "* #{TodoTXT.decorate(task, tag)}\n"
      end
    end
    text << %Q(\n!-- </td><td style="vertical-align:top;padding:15px"> --\n)
    text << "\n## Contexts\n"
    # Puts contexts
    contexts.each do |context, tasks|
      text << "\n### #{context}\n"
      tag = Regexp.new '[@]'+context+'\b'
      tasks.each do |task|
        text << "* #{TodoTXT.decorate(task, tag)}\n"
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
