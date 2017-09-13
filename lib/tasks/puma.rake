namespace :puma do
  desc "Start puma"
  task(:start) do
    config = Rails.root.join("config", "puma.rb")
    env    = ENV['RAILS_ENV'] || "development"
    `bundle exec puma -d -C #{config} -e #{env}`
  end

  desc "Halt puma"
  task(:halt) { puts `bundle exec pumactl -P #{pidfile} restart` }

  desc "Restart puma"
  task(:restart) { puts `bundle exec pumactl -P #{pidfile} restart` }

  desc "Phased-restart puma"
  task(:phased_restart) { puts `bundle exec pumactl -P #{pidfile} phased-restart` }

  desc "Stats puma"
  task(:stats) { puts `bundle exec pumactl -P #{pidfile} stats` }

  desc "Status puma"
  task(:status) { puts `bundle exec pumactl -P #{pidfile} status` }

  desc "Stop puma"
  task(:stop) { puts `bundle exec pumactl -P #{pidfile} stop` }

  def pidfile
    Rails.root.join("tmp", "pids", "puma.pid")
  end

  def puma_pid
    begin
      pid = File.read( Rails.root.join("tmp", "pids", "puma.pid") ).to_i
      return pid if Process.getpgid( pid )
    rescue
      puts "Puma doesn't seem to be running"
      exit
    end
  end
end
