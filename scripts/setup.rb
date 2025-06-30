# frozen_string_literal: true

# Server setup script
pipeline 'setup' do
  # Target all hosts
  host 'app1.example.com', roles: [:app, :web]
  host 'app2.example.com', roles: [:app, :web]
  host 'db.example.com', roles: [:db]

  # Set global variables
  set :ruby_version, '3.2.0'
  set :node_version, '18.x'

  task :install_dependencies do
    run <<~BASH
      # Update package lists
      sudo apt-get update

      # Install essential packages
      sudo apt-get install -y build-essential git curl
      sudo apt-get install -y nginx redis-server
    BASH
  end

  task :setup_ruby do
    run <<~BASH
      # Install rbenv
      git clone https://github.com/rbenv/rbenv.git ~/.rbenv
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
      echo 'eval "$(rbenv init -)"' >> ~/.bashrc
      source ~/.bashrc

      # Install ruby-build
      git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

      # Install Ruby
      rbenv install ${ruby_version}
      rbenv global ${ruby_version}
    BASH
  end

  task :setup_node do
    run <<~BASH
      # Install Node.js
      curl -fsSL https://deb.nodesource.com/setup_${node_version} | sudo -E bash -
      sudo apt-get install -y nodejs

      # Install Yarn
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      sudo apt-get update && sudo apt-get install -y yarn
    BASH
  end

  task :setup_nginx do
    # Upload nginx configuration
    upload_template 'nginx.conf', '/etc/nginx/sites-available/app'
    run 'sudo ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app'
    run 'sudo nginx -t && sudo systemctl restart nginx'
  end

  task :setup_app_service do
    # Upload systemd service configuration
    upload_template 'app.service', '/etc/systemd/system/app.service'
    run 'sudo systemctl daemon-reload'
    run 'sudo systemctl enable app'
  end

  task :setup do
    depends_on :install_dependencies,
              :setup_ruby,
              :setup_node,
              :setup_nginx,
              :setup_app_service
  end
end
