# frozen_string_literal: true

# Database management script
pipeline 'database' do
  # Target database hosts
  host 'db.example.com', roles: [:db]

  # Set database configuration
  set :db_name, 'app_production'
  set :db_user, 'app_user'
  set :db_password, ENV['DB_PASSWORD']

  task :create_database do
    run <<~SQL
      psql -U postgres -c "CREATE USER ${db_user} WITH PASSWORD '${db_password}';"
      psql -U postgres -c "CREATE DATABASE ${db_name} OWNER ${db_user};"
    SQL
  end

  task :migrate do
    run 'cd /var/www/app/current && RAILS_ENV=production bundle exec rake db:migrate'
  end

  task :seed do
    run 'cd /var/www/app/current && RAILS_ENV=production bundle exec rake db:seed'
  end

  task :backup do
    run <<~BASH
      timestamp=$(date +%Y%m%d_%H%M%S)
      pg_dump -U ${db_user} ${db_name} > /var/backups/${db_name}_${timestamp}.sql
      gzip /var/backups/${db_name}_${timestamp}.sql
    BASH
  end

  task :restore do
    run <<~BASH
      latest_backup=$(ls -t /var/backups/${db_name}_*.sql.gz | head -n1)
      gunzip -c $latest_backup | psql -U ${db_user} ${db_name}
    BASH
  end
end
