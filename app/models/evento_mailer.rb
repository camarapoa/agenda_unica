class EventoMailer < ActionMailer::Base
	
  ActionMailer::Base.delivery_method       = :smtp
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.default_charset       = "UTF-8"

  ActionMailer::Base.smtp_settings = {
#    :address => "10.150.150.165",
 #   :port    => 25,
  #  :domain  => "procempa.com.br"    
    
        
    :address => "cmpa-s03",
    :port    => 25,
    :domain  => "mail.camarapoa.rs.gov.br"    
  }  
  
  def envia_confirmacao_convocacao(evento, emails, responsavel)  	  	
    @recipients = emails
    @from = "agenda@camarapoa.rs.gov.br"
    @subject = "Convocação - #{evento.titulo}"
    @body["evento"] = evento  
    @body["responsavel"] = responsavel    
  end
  
  def envia_confirmacao_ciencia(evento, emails, responsavel)  	  	
    @recipients = emails
    @from = "agenda@camarapoa.rs.gov.br"
    @subject = "Ciência sobre Realização - #{evento.titulo}"
    @body["evento"] = evento  
    @body["responsavel"] = responsavel    
  end
  
  def envia_notificacao_solicitacao_recurso(evento, texto, emails)  	
  	@recipients = emails
    @from = "agenda@camarapoa.rs.gov.br"
    @subject = "Solicitação de Material - #{evento.titulo}"
    @body["evento"] = evento      
    @body["texto"] = texto
	end
	
	def envia_notificacao_erro_historico(evento, changes, operador, erro)
		@recipients = [operador.email, 'chuvisco@camarapoa.rs.gov.br']
		@from = "agenda@camarapoa.rs.gov.br"
    @subject = "Falha no Registro do Histórico"
    @body["evento"] = evento      
    @body["changes"] = changes
    @body["operador"] = operador    
    @body["erro"] = erro
	end

end
