# frozen_string_literal: true

# Todo List Web App
module Markita
  # Base class for Sinatra
  # :reek:UncommunicativeVariableName
  class Base
    # Uses todo.sh to get task list
    # Interprets the following keys:
    #   due:YYYY-MM-DD    Due date
    #   last:YYYY-MM-DD   Last done date
    #   every:N           Due date is N days after last done
    #   every:Weekday     Due date is on the given Weekday after last done
    # :reek:TooManyStatements
    module TodoTxt
      def self.decorate(task, tag = nil)
        task = task.dup
        task.sub! tag, '' if tag
        task.sub!(/^\d+/, '')
        task.sub!(/\([A-Z]\)/, '')
        task.gsub!(/([@+]\w+)/, '<small>\\1</small>')
        task.gsub!(/(\w+:\S+)/, '<small>\\1</small>')
        task.gsub!(/\s+/, ' ')
        task.strip!
        task
      end
    end

    # rubocop:disable Metrics/BlockLength
    get '/todotxt.html' do
      text = String.new
      text << "# [Todo.txt](https://github.com/todotxt/todo.txt-cli)\n"
      # Get tasks
      todos = `todo.sh -p list`.lines.grep(/^\d+ /).map(&:strip)
      # Get projects and contexts
      today    = Date.today
      due      = []
      projects = Hash.new { |h, k| h[k] = [] }
      contexts = Hash.new { |h, k| h[k] = [] }
      todos.each do |task|
        if /\+\w+/.match? task
          task.scan(/\+(\w+)/) { |m| projects[m[0]].push task }
        else
          projects['* Unspecified *'].push task
        end
        if /@\w+/.match? task
          task.scan(/@(\w+)/) { |m| contexts[m[0]].push task }
        else
          contexts['* Unspecified *'].push task
        end
        due.push task if / due:(?<date>\d\d\d\d-\d\d-\d\d)\b/=~task &&
                         today >= Date.parse(date)
        if / last:(?<date>\d\d\d\d-\d\d-\d\d)\b/=~task
          if / every:(?<n>\d+)\b/=~task
            due.push task if today >= Date.parse(date) + n.to_i
          elsif / every:(?<w>[SMTWF]\w+)\b/=~task &&
                today > Date.parse(date) &&
                w == %w[Sunday Monday Tuesday Wednesday Thursday Friday
                        Saturday][today.wday]
            due.push task
          end
        end
        due.uniq!
      end
      unless due.empty?
        text << "## Due\n"
        due.each do |task|
          text << "* #{TodoTxt.decorate(task)}\n"
        end
      end
      text << "|:\n"
      # Puts projects
      text << "## Projects\n"
      projects.each do |project, tasks|
        text << "### #{project}\n"
        tag = /[+]#{project}\b/
        tasks.each do |task|
          text << "* #{TodoTxt.decorate(task, tag)}\n"
        end
      end
      text << "|\n"
      text << "## Contexts\n"
      # Puts contexts
      contexts.each do |context, tasks|
        text << "### #{context}\n"
        tag = /[@]#{context}\b/
        tasks.each do |task|
          text << "* #{TodoTxt.decorate(task, tag)}\n"
        end
      end
      text << ":|\n"
      text << <<~VERSION
        ```
        #{`todo.sh -V`.strip}
        ```
      VERSION
      Markdown.new('Todo.txt').markdown text
    end
    # rubocop:enable Metrics/BlockLength
  end
end
