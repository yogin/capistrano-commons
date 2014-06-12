Capistrano::Configuration.instance(:must_exist).load do

  set(:branch) { run_locally("git symbolic-ref HEAD").gsub(/^refs\/heads\//, '').chomp }

end
