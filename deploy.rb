# frozen_string_literal: true

# Define hosts
host 'web01', user: 'root', ip: '10.1.1.2', key: '~/.ssh/id_rsa'

# Define roles
role :web, %w[web01]



# Define deployment task for web servers
task :deploy_web, roles: :web do
  # Stop service
  run 'free -m'

  # Upload configuration using ERB template
  upload_template './config/nginx.conf.erb', '/tmp/nginx.conf',
    domain_name: 'example.com',
    port: 3000,
    worker_processes: 4,
    worker_connections: 2048

  # Upload static configuration

  # Restart service
  run <<~SHELL
    ls -l /tmp/nginx.conf
    cat /tmp/nginx.conf
  SHELL

  # Check status
  run 'uptime'
end


