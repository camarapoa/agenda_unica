class EmprestimoMailer < ActionMailer::Base
	
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
 
  def envia_notificacao_nao_autorizacao_solicitacao(emprestimo, emails)  	
  	@recipients = emails
    @from = "agenda@camarapoa.rs.gov.br"
    @subject = "Negativa de Solicitação de Espaço"
    @body["emprestimo"] = emprestimo    
	end		
	
  def envia_notificacao_para_autorizacao_superior(emprestimo, emails)  	
  	@recipients = emails
    @from = "agenda@camarapoa.rs.gov.br"
    @subject = "Envio de Solicitação para Autorização Superior"
    @body["emprestimo"] = emprestimo    
	end			
	
  def envia_notificacao_autorizado_por_superior(emprestimo, emails)  	
  	@recipients = emails
    @from = "agenda@camarapoa.rs.gov.br"
    @subject = "Solicitação Autorizada por Superior"
    @body["emprestimo"] = emprestimo    
	end			
	

end

