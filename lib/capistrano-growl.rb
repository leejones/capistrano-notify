Capistrano::Configuration.instance.load do
  after :deploy, "growl:deploy:success"
  after :rollback, "growl:deploy:failure"
  after "deploy:setup", "growl:deploy:setup:success"

  before "moonshine:apply", "growl:moonshine:apply"
  
  set :growl_stickyness, true
  set :growl_title, "Capistrano"
  
  namespace :growl do
    namespace :deploy do
      task :success do
        set :growl_message, "The deploy to #{fetch(:application)} finished."
        growlnotify
      end

      task :failure do
        set :growl_message, "The deploy to #{fetch(:application)} failed."
        growlnotify
      end
      
      namespace :setup do
        task :success do
          set :growl_message, "The deploy:setup for #{fetch(:application)} finished."
          growlnotify
        end        
      end
    end
  
    namespace :moonshine do
      task :apply do
        set :growl_stickyness, false
        set :growl_message, "Moonshine is applying the #{fetch(:moonshine_manifest)} for #{fetch(:application)}."
        growlnotify      
      end
    end
    
    task :growlnotify do
      command = []
      command << "growlnotify"
      command << "--message '#{fetch(:growl_message)}'"
      command << "--sticky" if fetch(:growl_stickyness)
      command << "--title '#{fetch(:growl_title)}'"
      system command.join(' ')
    end
  end
end