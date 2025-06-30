# frozen_string_literal: true

# Main deployment script
pipeline 'main' do
  # Define target hosts
  host 'app1.example.com', roles: [:app, :web]
  host 'app2.example.com', roles: [:app, :web]
  host 'db.example.com', roles: [:db]

  # Set global variables
  set :app_name, 'my_app'
  set :deploy_to, '/var/www/${app_name}'
  set :keep_releases, 5

  # Define tasks
  task :check_requirements do
    run 'ruby -v'
    run 'node -v'
    run 'git --version'
  end

  task :setup_directories do
    run "mkdir -p ${deploy_to}"
    run "mkdir -p ${deploy_to}/releases"
    run "mkdir -p ${deploy_to}/shared"
  end

  task :deploy do
    depends_on :check_requirements, :setup_directories

    run 'git clone https://github.com/user/repo.git ${deploy_to}/releases/$(date +%Y%m%d%H%M%S)'
    run 'ln -sfn ${deploy_to}/releases/$(ls -t ${deploy_to}/releases | head -n1) ${deploy_to}/current'
  end

  task :restart_services do
    run 'sudo systemctl restart nginx'
    run 'sudo systemctl restart app'
  end

  task :cleanup do
    run "cd ${deploy_to}/releases && ls -t | tail -n +${keep_releases + 1} | xargs rm -rf"
  end
end
