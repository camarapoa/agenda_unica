class TipoEvento  < ActiveRecord::Base
	
  set_table_name :agenda_tipos_eventos
  
  default_scope :order => 'nome'
  
  def setores_responsaveis
  	self.setores_responsaveis_ids.split(';')
	end
	
	def emprestimo_restrito?
		return true if self.restricao_emprestimo == 'sim'
		return false 
	end
	
	def self.solicitaveis_por_tipo_setor(logged_setor_id)				
		tipos_eventos = TipoEvento.all
		tipos_autorizados = []		
		for tipo in tipos_eventos
			if tipo.restricao_emprestimo == 'nao'
				tipos_autorizados << tipo
			else
				tipos_autorizados << tipo if tipo.setores_responsaveis.include?(logged_setor_id.to_s)				
			end
		end				
		return tipos_autorizados		
	end
	
	
end