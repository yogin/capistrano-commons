Capistrano::Configuration.instance(:must_exist).load do

  class Array
    def count_by(&block)
      groups = self.group_by(&block)
      groups.each { |key, group| groups[key] = group.size }
    end

    def counts
      count_by { |o| o }
    end
  end

  def github_commit_link(sha)
    "https://github.com/#{fetch(:github_project)}/commit/#{sha}"
  end

  def github_pullrequest_link(pr)
    "https://github.com/#{fetch(:github_project)}/pull/#{pr}"
  end

  def github_compare_link(a, b)
    "https://github.com/#{fetch(:github_project)}/compare/#{a}...#{b}"
  end

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
