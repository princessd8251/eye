# Example: now to run unicorn, and monitor its childs processes

RUBY = '/usr/local/ruby/1.9.3/bin/ruby' # ruby on the server
RAILS_ENV = 'production'

Eye.application "rails_unicorn" do
  env "RAILS_ENV" => RAILS_ENV
  env "PATH" => "#{File.dirname(RUBY)}:#{ENV['PATH']}" # unicorn requires to be `ruby` in path (for soft restart)
  working_dir File.expand_path(File.join(File.dirname(__FILE__), %w[ processes ]))

  process("unicorn") do
    pid_file "tmp/pids/unicorn.pid"
    start_command "#{RUBY} ./bin/unicorn -Dc ./config/unicorn.rb -E #{RAILS_ENV}"
    stop_command "kill -QUIT {{PID}}"
    restart_command "kill -USR2 {{PID}}"
    stdall "log/unicorn.log"

    check :cpu, :every => 30, :below => 80, :times => 3
    check :memory, :every => 30, :below => 150.megabytes, :times => [3,5]

    start_timeout 30.seconds
    stop_grace 5.seconds
    restart_grace 30.seconds

    monitor_children do
      stop_command "kill -QUIT {{PID}}"
      check :cpu, :every => 30, :below => 80, :times => 3
      check :memory, :every => 30, :below => 150.megabytes, :times => [3,5]
    end
  end

end
