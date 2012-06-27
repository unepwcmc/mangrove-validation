# Start a worker with proper env vars and output redirection
def run_worker(queue, count = 1)
  puts "Starting #{count} worker(s) with QUEUE: #{queue}"
  ops = {:pgroup => true, :err => [(Rails.root + "log/workers_error.log").to_s, "a"],
                          :out => [(Rails.root + "log/workers.log").to_s, "a"]}
  env_vars = {
    "VERBOSE" => '1',
    "QUEUE" => queue.to_s,
    "RAILS_ENV" => Rails.env
  }
  count.times {
    ## Using Kernel.spawn and Process.detach because regular system() call would
    ## cause the processes to quit when capistrano finishes
    pid = spawn(env_vars, "bundle exec rake resque:work", ops)
    Process.detach(pid)
  }
end

# Start a scheduler, requires resque_scheduler >= 2.0.0.f
def run_scheduler
  puts "Starting resque scheduler"
  env_vars = {
    "BACKGROUND" => "1",
    "PIDFILE" => (Rails.root + "tmp/pids/resque_scheduler.pid").to_s,
    "VERBOSE" => "1",
    "RAILS_ENV" => Rails.env
  }
  ops = {:pgroup => true, :err => [(Rails.root + "log/scheduler_error.log").to_s, "a"],
                          :out => [(Rails.root + "log/scheduler.log").to_s, "a"]}
  pid = spawn(env_vars, "bundle exec rake resque:scheduler", ops)
  Process.detach(pid)
end

namespace :resque do
  task :setup => :environment

  desc "Restart running workers"
  task :restart_workers => :environment do
    Rake::Task['resque:stop_workers'].invoke
    Rake::Task['resque:start_workers'].invoke
  end
  
  desc "Quit running workers"
  task :stop_workers => :environment do
    if Resque.workers.length > 0
      pids = Resque.workers[0].worker_pids.join(" ")

      syscmd = "kill -s QUIT #{pids}"
      puts "Running syscmd: #{syscmd}"
      puts `#{syscmd}`
    else
      puts "No workers to kill"
    end
  end
  
  desc "Start workers"
  task :start_workers => :environment do
    run_worker("download_serve", 2)
  end

  desc "Restart scheduler"
  task :restart_scheduler => :environment do
    Rake::Task['resque:stop_scheduler'].invoke
    Rake::Task['resque:start_scheduler'].invoke
  end

  desc "Quit scheduler"
  task :stop_scheduler => :environment do
    pidfile = Rails.root + "tmp/pids/resque_scheduler.pid"
    if !File.exists?(pidfile)
      puts "Scheduler not running"
    else
      pid = File.read(pidfile).to_i
      syscmd = "kill -s QUIT #{pid}"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
      FileUtils.rm_f(pidfile)
    end
  end

  desc "Start scheduler"
  task :start_scheduler => :environment do
    run_scheduler
  end

  desc "Reload schedule"
  task :reload_schedule => :environment do
    pidfile = Rails.root + "tmp/pids/resque_scheduler.pid"

    if !File.exists?(pidfile)
      puts "Scheduler not running"
    else
      pid = File.read(pidfile).to_i
      syscmd = "kill -s USR2 #{pid}"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
    end
  end
end

# http://stackoverflow.com/questions/6137570/resque-enqueue-failing-on-second-run
require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'

  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
