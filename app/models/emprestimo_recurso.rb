class EmprestimoRecurso < ActiveRecord::Base
	
	set_table_name :agenda_emprestimos_recursos
	
	formatted_date :data_inicio, :data_termino
	
	belongs_to :recurso_evento, :foreign_key => 'recurso_evento_id'
	belongs_to :setor_solicitante, :class_name => "Setor", :foreign_key => 'setor_solicitante_id'	
	belongs_to :funcionario_solicitante , :class_name => "Pessoa", :foreign_key => 'created_by'
	belongs_to :funcionario_autorizador , :class_name => "Pessoa", :foreign_key => 'funcionario_autorizador_id'		
	belongs_to :atendente,  :class_name => "Pessoa", :foreign_key => 'updated_by'
	has_many	 :mensagens
	
	validates_presence_of				:recurso_evento_id, :quantidade, :justificativa, :local
	validates_numericality_of  	:quantidade
	validates_inclusion_of      :quantidade, :in => 1..400, :message => "precisa ser maior do que zero"
	validates_presence_of       :data_inicio, :data_termino	, :horario_inicio, :horario_termino
	
	before_create lambda {|emprestimo| emprestimo.status = 'por_atender' }
	
	named_scope	:ativos, 	:conditions => ["(agenda_emprestimos_recursos.status = 'em_atendimento' OR  agenda_emprestimos_recursos.status =  'por_atender') AND getdate() < CONVERT(VARCHAR(8), data_termino, 112) + ' ' + horario_termino"], :include => ['setor_solicitante','funcionario_solicitante'],  :order => 'created_on desc'	
	named_scope :encerrados, :conditions => ["agenda_emprestimos_recursos.status = 'nao_autorizado' or agenda_emprestimos_recursos.status = 'atendido' or agenda_emprestimos_recursos.status = 'cancelado' or (getdate() > (CONVERT(VARCHAR(8), data_termino, 112) + ' ' + horario_termino))" ], :include => ['setor_solicitante','funcionario_solicitante'], :order => 'created_on desc'		
	named_scope	:emprestados, :conditions => ["getdate() < CONVERT(VARCHAR(8), data_termino, 112) + ' ' + horario_termino AND agenda_emprestimos_recursos.status <> 'nao_autorizado'  AND agenda_emprestimos_recursos.status <> 'cancelado' "]
	named_scope :por_setor, lambda { |setor_id| { :conditions => { :setor_solicitante_id => setor_id } } }
	named_scope :periodo_between, lambda { |inicio, termino| { :conditions => ['data_inicio >= ? AND data_termino <= ?', inicio.beginning_of_day, termino.end_of_day] } }
	named_scope	:por_recurso, lambda { |recurso_id| { :conditions => { :recurso_evento_id => recurso_id } } }
	named_scope	:concomitantes, lambda {|inicio, termino| {:conditions => ["not (((CONVERT(VARCHAR(8), data_inicio, 112) + ' ' + horario_inicio) > ?) or ((CONVERT(VARCHAR(8), data_termino, 112) + ' ' + horario_termino) < ?))", termino, inicio] } }	
	named_scope	:administrados_por, lambda { |setor_administrador_id| { :conditions => ["agenda_recursos_eventos.setor_responsavel_id = #{setor_administrador_id}"], :include => :recurso_evento } }
	named_scope	:por_atender,    :conditions => { :status => :por_atender }, :include => ['setor','pessoa'], :order => 'created_on desc'	
	named_scope	:em_atendimento, :conditions => { :status => :em_atendimento }, :include => ['setor','pessoa'], :order => 'created_on desc'		
	named_scope :limit, lambda { |num| { :limit => num } }
	
	def validate
		inicio, fim = FormattedDate::Conversion.to_datetime("#{data_inicio_before_type_cast} #{horario_inicio}", "#{data_termino_before_type_cast} #{horario_termino}", :format => '%d/%m/%Y %H:%M')
    errors.add_to_base('Período do empréstimo inválido') if !inicio || !fim || inicio >= fim    
    if inicio && fim && inicio < fim  && self.quantidade.present? && quantidade > 0 && self.recurso_evento.present?
    	quantidade_disponivel = RecursoEvento.quantidade_disponivel(self, self.recurso_evento, "#{self.data_inicio.strftime('%Y%m%d')} #{self.horario_inicio}"  ,  "#{self.data_termino.strftime('%Y%m%d')} #{self.horario_termino}")    	    	
    	errors.add(:quantidade, "Material indisponível para o período. Total disponível para o período: #{quantidade_disponivel} item(ns)") if self.new_record? && self.quantidade > quantidade_disponivel
    end         
    errors.add_to_base("Justificativa deve ser preenchida em caso de negativa") if self.status == 'nao_autorizado' and !self.mensagem_finalizacao.present?
    errors.add_to_base("Deve ser enviada mensagem ao administrador superior") if self.status == 'aguardando_autorizacao_superior' and !self.mensagem_autorizacao_superior.present?    
	end
	
	def status_real		
		# melhorar isso aqui no futuro... existe porque há solicitações expiradas,
		# um status que deveria ser atualizado através de um temporizador
		data = "#{self.data_termino.strftime('%Y%m%d')} #{self.horario_termino}"
		return 'expirado'  if self.status == 'por_atender' && DateTime.now > data.to_datetime
		return self.status
	end	
	
	
end