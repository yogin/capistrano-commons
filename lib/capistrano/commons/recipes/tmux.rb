Capistrano::Configuration.instance(:must_exist).load do

  namespace :deploy do

    desc "Check if we are running inside a tmux or screen session"
    task :check_for_tmux do
      if exists?(:tmux_required) && tmux_required && !(ENV['TMUX'] || ENV['STY'])
        logger.important "You need to be in a tmux or screen session to deploy to #{stage}!"
        abort
      end
    end

  end

  on :start, 'deploy:check_for_tmux'

end
