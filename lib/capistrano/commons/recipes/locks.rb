Capistrano::Configuration.instance(:must_exist).load do

  namespace :deploy do

    desc "Lock deploys to prevent simultaneous deploys to the same stage"
    task :lock, :roles => :app do
      check_lock

      now = Time.now.strftime("%c %Z")
      message = ENV['MESSAGE'] || ENV['MSG'] || fetch(:lock_message, "Deploying application")
      lock_message = "Deploy locked on #{stage} since #{now}: #{message}"

      put lock_message, "#{shared_path}/deploy.lock", :mode => 0644
    end

    desc "Check for existing locks"
    task :check_lock, :roles => :app do
      # This also works when the lock file is missing :)
      data = capture("cat #{shared_path}/deploy.lock 2>/dev/null ; echo").to_s.strip

      if data.empty?
        logger.info "No locks found for #{stage}"
      else
        logger.important "#{data}"

        if ENV['FORCE_DEPLOY']
          logger.important "You have forced the deploy lock on #{stage}!"
        else
          abort
        end
      end
    end

    desc "Remove deploy locks from a stage"
    task :unlock, :roles => :app do
      logger.info "Unlocking deploys on #{stage}!"
      run "rm -f #{shared_path}/deploy.lock"
    end

  end

  before 'deploy', 'deploy:lock'
  after 'deploy', 'deploy:unlock'

end
