class Emprestimo < ActiveRecord::Base
	
	set_table_name :agenda_emprestimos_espacos
	
	formatted_date :data_inicio, :data_termino
	
	belongs_to	:espaco, :class_name => 'Espaco', :foreign_key => 'espaco_id'
	belongs_to	:funcionario_solicitante, :class_name => 'Pessoa', :foreign_key => 'funcionario_solicitante_id'
	belongs_to	:funcionario_autorizador, :class_name => 'Pessoa', :foreign_key => 'funcionario_autorizador_id'
	belongs_to	:setor_solicitante, :class_name => 'Setor', :foreign_key => 'setor_solicitante_id'	
	belongs_to	:tipo_evento
	
	before_save   { |emprestimo| emprestimo.data_termino = emprestimo.data_inicio } #emprestimo por 1 dia somente

	validates_presence_of :espaco_id, :descricao, :proponente, :contato, :categoria, :tipo_evento_id, :acceptance, :numero_participantes
	validates_presence_of :data_inicio, :horario_inicio, :horario_termino	
	validates_numericality_of	:numero_participantes
	validates_inclusion_of :numero_participantes, :in => 1..400, :message => "precisa estar entre 1 e 500 pessoas"
			
	named_scope	:ativos, 	:conditions => ["agenda_emprestimos_espacos.status <> 'encerrado' and agenda_emprestimos_espacos.status <> 'cancelado' and agenda_emprestimos_espacos.status <> 'nao_autorizado' and agenda_emprestimos_espacos.status <> 'atendido' and getdate() < CONVERT(VARCHAR(8), data_termino, 112) + ' ' + horario_termino"], :include => ['setor_solicitante','funcionario_solicitante'],  :order => 'created_on desc'	
	named_scope :por_atender, :conditions => {:status => 'por_atender'}
	named_scope :aguardando_autorizacao_superior, :conditions => {:status => 'aguardando_autorizacao_superior'}
	named_scope :autorizados_por_superior, :conditions => {:status => 'autorizado_por_superior'}
	named_scope :por_setor, lambda { |setor_id| { :conditions => { :setor_solicitante_id => setor_id } } }
	named_scope :encerrados, :conditions => ["agenda_emprestimos_espacos.status = 'nao_autorizado' or agenda_emprestimos_espacos.status <> 'cancelado' or agenda_emprestimos_espacos.status = 'atendido' or (getdate() > (CONVERT(VARCHAR(8), data_termino, 112) + ' ' + horario_termino))" ], :include => ['setor_solicitante','funcionario_solicitante'], :order => 'created_on desc'		
	named_scope :periodo_between, lambda { |inicio, termino| { :conditions => ['data_inicio >= ? AND data_termino <= ?', inicio.beginning_of_day, termino.end_of_day] } }
	named_scope :limit, lambda { |num| { :limit => num , :order => "created_on desc"} }
	
	def validate
		inicio, fim = FormattedDate::Conversion.to_datetime("#{data_inicio_before_type_cast} #{horario_inicio}", "#{data_termino_before_type_cast} #{horario_termino}", :format => '%d/%m/%Y %H:%M')
    errors.add_to_base('Período do empréstimo inválido') if !inicio || !fim || inicio >= fim    
    errors.add_to_base('Justificativa deve ser preenchida em caso de não autorização do empréstimo') if self.status == 'nao_autorizado' && !self.resultado.present?           
    errors.add_to_base('Justificativa deve ser preenchida em caso de cancelamento') if self.status == 'cancelado' && !self.justificativa_cancelamento.present?           
    if inicio && fim && (inicio <= fim) 			
			errors.add_to_base('Espaço já alocado para outro evento no período') if !Espaco.espaco_disponivel?(nil, self, self.espaco, "#{self.data_inicio.strftime('%Y%m%d')} #{self.horario_inicio}"  ,  "#{self.data_termino.strftime('%Y%m%d')} #{self.horario_termino}")
		end		
		if self.espaco.present? && self.numero_participantes.present?
			errors.add_to_base("Capacidade do local ultrapassada. Máximo de #{espaco.capacidade} participantes") if espaco.capacidade.present? && self.numero_participantes > espaco.capacidade
		end
		errors.add(:mensagem_ao_super, 'deve ser preenchida antes do envio') if self.status == 'aguardando_autorizacao_superior' && !self.mensagem_ao_super.present?
		errors.add_to_base('Informe a razão da autorização antes do envio') if self.status == 'autorizado_por_superior' && !self.resultado.present?
		
	end
	
	def before_create
		self.status = 'por_atender'		
	end
	
	def status_real		
		# melhorar isso aqui no futuro... existe porque há solicitações expiradas,
		# um status que deveria ser atualizado através de um temporizador
		data = "#{self.data_termino.strftime('%Y%m%d')} #{self.horario_termino}"
		return 'expirado'  if self.status == 'por_atender' && DateTime.now > data.to_datetime
		return self.status
	end
	

	
end
