# frozen_string_literal: true

# Backup operations script
pipeline 'backup' do
  # Target all hosts
  host 'app1.example.com', roles: [:app, :web]
  host 'app2.example.com', roles: [:app, :web]
  host 'db.example.com', roles: [:db]

  # Set backup configuration
  set :backup_dir, '/var/backups'
  set :keep_backups, 10

  task :backup_database do
    only :db
    run <<~BASH
      timestamp=$(date +%Y%m%d_%H%M%S)
      pg_dump -U ${db_user} ${db_name} > ${backup_dir}/${db_name}_${timestamp}.sql
      gzip ${backup_dir}/${db_name}_${timestamp}.sql
    BASH
  end

  task :backup_uploads do
    only [:app, :web]
    run <<~BASH
      timestamp=$(date +%Y%m%d_%H%M%S)
      tar -czf ${backup_dir}/uploads_${timestamp}.tar.gz /var/www/app/shared/public/uploads
    BASH
  end

  task :backup_logs do
    run <<~BASH
      timestamp=$(date +%Y%m%d_%H%M%S)
      tar -czf ${backup_dir}/logs_${timestamp}.tar.gz /var/log/app
    BASH
  end

  task :cleanup_old_backups do
    run <<~BASH
      cd ${backup_dir}
      ls -t *.sql.gz | tail -n +${keep_backups + 1} | xargs rm -f
      ls -t *.tar.gz | tail -n +${keep_backups + 1} | xargs rm -f
    BASH
  end

  task :backup do
    depends_on :backup_database,
              :backup_uploads,
              :backup_logs,
              :cleanup_old_backups
  end
end
