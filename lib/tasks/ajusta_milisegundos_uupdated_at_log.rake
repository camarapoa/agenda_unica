namespace :db do     
  
  task :ajusta_milisegundos_uupdated_at_log => :environment do
  	
  	logs = LogEvento.all
    
  	i=1
  	for log in logs  		
  		y log.updated_at
  		log.updated_at = log.updated_at
  		log.save(false)
  		y i
  		i = i + 1
  		
		end
  	
  end
  
end    