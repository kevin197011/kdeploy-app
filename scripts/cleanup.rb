# frozen_string_literal: true

# Cleanup operations script
pipeline 'cleanup' do
  # Target all hosts
  host 'app1.example.com', roles: [:app, :web]
  host 'app2.example.com', roles: [:app, :web]
  host 'db.example.com', roles: [:db]

  # Set cleanup configuration
  set :app_name, 'my_app'
  set :deploy_to, '/var/www/${app_name}'
  set :keep_releases, 5
  set :keep_logs, 7

  task :cleanup_releases do
    run <<~BASH
      cd ${deploy_to}/releases
      ls -t | tail -n +${keep_releases + 1} | xargs rm -rf
    BASH
  end

  task :cleanup_logs do
    run <<~BASH
      find /var/www/app/current/log -name "*.log.*" -mtime +${keep_logs} -exec rm {} \;
      find /var/log/nginx -name "*.log.*" -mtime +${keep_logs} -exec sudo rm {} \;
    BASH
  end

  task :cleanup_temp do
    run <<~BASH
      find /tmp -name "${app_name}-*" -mtime +1 -exec rm -rf {} \;
      find /var/tmp -name "${app_name}-*" -mtime +1 -exec rm -rf {} \;
    BASH
  end

  task :cleanup do
    depends_on :cleanup_releases,
              :cleanup_logs,
              :cleanup_temp
  end
end
