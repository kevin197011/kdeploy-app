# frozen_string_literal: true

# Rollback operations script
pipeline 'rollback' do
  # Target application hosts
  host 'app1.example.com', roles: [:app, :web]
  host 'app2.example.com', roles: [:app, :web]

  # Set deployment configuration
  set :app_name, 'my_app'
  set :deploy_to, '/var/www/${app_name}'

  task :list_releases do
    run "ls -lt ${deploy_to}/releases"
  end

  task :rollback_code do
    run <<~BASH
      current_release=$(readlink ${deploy_to}/current)
      previous_release=$(ls -t ${deploy_to}/releases | head -n 2 | tail -n 1)
      ln -sfn ${deploy_to}/releases/$previous_release ${deploy_to}/current
    BASH
  end

  task :rollback_database do
    run 'cd ${deploy_to}/current && RAILS_ENV=production bundle exec rake db:rollback STEP=1'
  end

  task :restart_services do
    run 'sudo systemctl restart app'
    run 'sudo systemctl restart nginx'
  end

  task :rollback do
    depends_on :list_releases,
              :rollback_code,
              :rollback_database,
              :restart_services
  end
end
