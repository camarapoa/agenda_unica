class Notifier < ActionMailer::Base 
 
  helper :application

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.default_charset = "UTF-8"
  ActionMailer::Base.raise_delivery_errors = true
  
  ActionMailer::Base.smtp_settings = {
    :address => "10.150.150.165" ,
    :port => 25,
    :domain => "procempa.com.br"
  }
  def notifica_setor(evento, eventos_servicos,setor, funcionario)        
    @subject = "Solicitação de serviço -  #{evento.tipo_evento.nome}"    
    @recipients = setor.email
    @from = "AGENDA CMPA<assinfo@camarapoa.rs.gov.br>"    
    @body['evento'] = evento    
    @body['eventos_servicos'] = eventos_servicos        
    @body['setor'] = setor    
    @body['funcionario'] = funcionario   
    content_type "text/html" 
  end
  
end