server "examlple.com", :web, :app, :db, :primary => true

set :application, "example.com"
set :repository, "<your_repo>"
set :branch, "master"
set :scm, :git
set :deploy_via, :remote_cache
set :copy_exclude, [ '.git' ]
set :use_sudo, false

set(:user) { "<your_username>" }
set(:group) { user }
set :group_writable, false
set :deploy_to, "/path/to#{application}"
set :keep_releases, 2
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:update", "deploy:cleanup"

namespace :deploy do
  

  desc "Sync uploads folders (server uploads and repo uploads)"
  task :sync_uploads_before_symlink do
    run "rsync -avz #{current_release}/wp-content/uploads/ #{shared_path}/uploads"
  end

  desc "WordPress symlinks"
  task :wp_symlinks do
    run "rm -rf #{latest_release}/wp-content/uploads"
    run "ln -nfs #{shared_path}/uploads #{latest_release}/wp-content"
    run "ln -nfs #{shared_path}/config/wp-config.php #{latest_release}"
  end
  after "deploy:finalize_update", "deploy:sync_uploads_before_symlink", "deploy:wp_symlinks"


  # Setup 
  #
  # persist upload across deployments by storing in a location outside the application
  desc "Initial setup of application environment"
  task :setup_directories do
    run "mkdir -p #{shared_path}/uploads"
    run "mkdir -p #{shared_path}/config"
  end
  after "deploy:setup", "deploy:setup_directories"

  desc "Drop a wp-config.php file in the shared/config directory"
  task :upload_config do
    top.upload("wp-config.php", "#{shared_path}/config/wp-config.php",  {:via => :sftp, :mkdir => true})
  end
  after "deploy:setup", "deploy:upload_config"

  
end

