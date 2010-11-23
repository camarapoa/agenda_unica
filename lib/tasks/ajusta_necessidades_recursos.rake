namespace :db do 
    
  
  task :ajusta_necessidades_recursos => :environment do
  	
  	emprestimos = Emprestimo.all(:conditions => "evento_id is not null and necessidades is not null ")
    
  	for emp in emprestimos
  		
  		evento = Evento.find(emp.evento_id)  	
  		if evento and !evento.observacao.present?
  			y emp.id
  		evento.observacao = emp.necessidades
  		evento.save(false)
		end
		end
  	
  
  
  end
  
end    