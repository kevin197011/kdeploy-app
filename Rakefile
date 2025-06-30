# frozen_string_literal: true

require 'time'

# Default task runs, then pushes code
task default: %w[push]

# Auto-commit and push changes
task :push do
  system 'git add .'
  system "git commit -m 'Update #{Time.now}'"
  system 'git pull'
  system 'git push'
end
