class RecursoAlocado < ActiveRecord::Base
  
  belongs_to :evento
  belongs_to :recurso_evento
  belongs_to :emprestimo_recurso
  
  set_table_name :agenda_recursos_alocados
  
  validates_presence_of     :quantidade, :recurso_evento_id
  validates_numericality_of :quantidade, :allow_nil => true
  validate                  :validate_quantidade_disponivel
  
  private
  
    def validate
      #if self.recurso_evento && self.recurso_evento.tipo == 'material' 			
       # quantidade_disponivel = RecursoEvento.itens_disponiveis(self.evento,self.recurso_evento.id)
        #errors.add_to_base("Não há disponibilidade do item solicitado") if quantidade_disponivel == 0
      #end
    end
    
    def validate_quantidade_disponivel
    	return if !self.quantidade.present? || !self.recurso_evento.present?    		      
      quantidade_disponivel =  RecursoEvento.quantidade_disponivel(self.recurso_evento, "#{self.evento.data_inicio.strftime('%Y%m%d')} #{self.evento.horario_inicio}"  ,  "#{self.evento.data_termino.strftime('%Y%m%d')} #{self.evento.horario_termino}")    	    	            
      errors.add(:quantidade, "não disponível ( #{quantidade_disponivel}item(ns) disponível(eis) )") if quantidade.present? && quantidade > quantidade_disponivel
    end
  
end