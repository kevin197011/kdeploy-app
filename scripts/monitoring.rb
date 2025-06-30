# frozen_string_literal: true

# Health checks and monitoring script
pipeline 'monitoring' do
  # Target all hosts
  host 'app1.example.com', roles: [:app, :web]
  host 'app2.example.com', roles: [:app, :web]
  host 'db.example.com', roles: [:db]

  task :check_system_resources do
    run <<~BASH
      echo "Memory Usage:"
      free -h
      echo "\nDisk Usage:"
      df -h
      echo "\nCPU Load:"
      uptime
    BASH
  end

  task :check_services do
    run <<~BASH
      echo "Nginx Status:"
      sudo systemctl status nginx
      echo "\nApp Status:"
      sudo systemctl status app
      echo "\nRedis Status:"
      sudo systemctl status redis-server
    BASH
  end

  task :check_logs do
    run <<~BASH
      echo "Last 50 lines of application log:"
      tail -n 50 /var/www/app/current/log/production.log
      echo "\nLast 50 lines of nginx error log:"
      sudo tail -n 50 /var/log/nginx/error.log
    BASH
  end

  task :check_database do
    only :db
    run <<~BASH
      echo "PostgreSQL Status:"
      sudo systemctl status postgresql
      echo "\nDatabase Size:"
      psql -U ${db_user} -d ${db_name} -c "\l+"
    BASH
  end

  task :monitor do
    depends_on :check_system_resources,
              :check_services,
              :check_logs,
              :check_database
  end
end
