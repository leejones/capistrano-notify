Capistrano::Configuration.instance.load do
  after :deploy, "notify:deploy:success"
  after :rollback, "notify:deploy:failure"
  after "deploy:setup", "notify:deploy:setup:success"
  before "moonshine:apply", "notify:moonshine:apply"
  
  set :notify_stickyness, true
  set :notify_title, "Capistrano"
  
  namespace :notify do
    namespace :deploy do
      task :success do
        set :notify_message, "The deploy to #{fetch(:application)} finished."
        notify
      end

      task :failure do
        set :notify_message, "The deploy to #{fetch(:application)} failed."
        notify
      end
      
      namespace :setup do
        task :success do
          set :notify_message, "The deploy:setup for #{fetch(:application)} finished."
          notify
        end        
      end
    end
  
    namespace :moonshine do
      task :apply do
        set :notify_stickyness, false
        set :notify_message, "Moonshine is applying the #{fetch(:moonshine_manifest)} for #{fetch(:application)}."
        notify      
      end
    end
    
    task :notify do
      command = []
      command << "growlnotify"
      command << "--message '#{fetch(:notify_message)}'"
      command << "--sticky" if fetch(:notify_stickyness)
      command << "--title '#{fetch(:notify_title)}'"
      system command.join(' ')
    end
  end
end