Capistrano::Configuration.instance(:must_exist).load do

  namespace :deploy do

    desc "Tag the release"
    task :tag_release do
      if exists?(:tag_releases) && tag_releases
        set :latest_git_tag, "#{tag_base}.#{deploys_today + 1}"
        message = Shellwords.shellescape(deploy_message)

        run_locally "git tag -a #{latest_git_tag} -m #{message} #{head_revision} && git push origin #{latest_git_tag}"
      end
    end

  end

  set(:tag_base) { "#{stage}.#{Time.now.utc.to_date}" }
  set(:deploys_today) { run_locally("git tag -l '#{tag_base}*'").split.length }
  set(:head_revision) { run_locally("git rev-parse HEAD").strip }

  set(:release_authors) do
    authors = run_locally "git log --pretty='%an' --no-merges #{current_revision}...#{head_revision}"
    author_counts = authors.split("\n").counts
    
    if author_counts.empty?
      "\tNo commits since the last deploy!?"
    else
      author_counts.to_a.map(&:reverse).sort.reverse.map { |count, author| "\t#{author}: #{count} commits" }.join("\n")
    end
  end

  set(:deploy_message) do
    message = []
    message << "Deploying branch #{branch} to ##{stage}!"
    message << ""
    message << "Release contributors:"
    message << release_authors
    message << ""
    message << "Permalink: #{github_compare_link(current_revision, head_revision)}"
    message.join("\n")
  end

  before 'deploy:update', 'deploy:tag_release'

end
