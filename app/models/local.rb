class Local < ActiveRecord::Base

  #belongs_to :setor # Setor responsável pelo agendamento de eventos no local.
  has_many   :eventos, :through => :locais_eventos
  
  set_table_name :agenda_locais
  
  default_scope	:order => 'nome,complemento'  
  
  # evento_new e emprestimo_new são passados para se verificar se a sobreposição não está ocorrendo com o mesmo evento ou emprestimo 
  # verificação necessária na edição
	def self.espaco_disponivel?(evento_new, emprestimo_new, espaco, periodo_inicial, periodo_final) # no formato "yyyymmdd HH:MM"				
		return true if evento_new && (!evento_new.local_id.present? && evento_new.outro_local.present )
		intervalos_solicitados = UtilDate.date_time_intervals(periodo_inicial, periodo_final, 5)		
		eventos = Evento.ativos.periodo_between(periodo_inicial.to_datetime, periodo_final.to_datetime)		
		emprestimos = Emprestimo.ativos.periodo_between(periodo_inicial.to_datetime, periodo_final.to_datetime)			
		for evento in eventos 			
			intervalos_evento = UtilDate.date_time_intervals("#{evento.data_inicio.strftime('%Y%m%d')} #{evento.horario_inicio}", "#{evento.data_termino.strftime('%Y%m%d')} #{evento.horario_termino}", 5)
			sobreposicao = intervalos_evento & intervalos_solicitados
			return false if evento_new && !evento_new.new_record? && !sobreposicao.empty? && (espaco.id == evento.local_id) && (evento_new.id != evento.id)
			return false if evento_new &&  evento_new.new_record? && !sobreposicao.empty? && (espaco.id == evento.local_id)
			return false if emprestimo_new && !sobreposicao.empty? && (espaco.id == evento.local_id)						
		end
		for emprestimo in emprestimos				
			intervalos_emprestimo = UtilDate.date_time_intervals("#{emprestimo.data_inicio.strftime('%Y%m%d')} #{emprestimo.horario_inicio}", "#{emprestimo.data_termino.strftime('%Y%m%d')} #{emprestimo.horario_termino}", 5)			
			sobreposicao = intervalos_emprestimo & intervalos_solicitados
			#emprestimo ja salvo - edição
			return false if emprestimo_new && !emprestimo_new.new_record? && !sobreposicao.empty? && (espaco.id == emprestimo.espaco_id) && (emprestimo_new.id != emprestimo.id)
			#emprestimo_new pode ainda não ter sido salvo - new record
			return false if emprestimo_new &&  emprestimo_new.new_record? && !sobreposicao.empty? && (espaco.id == emprestimo.espaco_id)
			return false if evento_new && !sobreposicao.empty? && (espaco.id == emprestimo.espaco_id)
		end		
		return true				
	end
	
	def self.autorizados_para_usuario(setor_id)
		locais = Local.all
		autorizados = []
		for local in locais
			setores_responsaveis_ids = local.setores_responsaveis_ids.split(';')
			autorizados << local if  setores_responsaveis_ids.include?(setor_id.to_s)			
		end
		return autorizados				
	end


	# Às terças-feiras, por regimento, as salas de commissões e plenario ana terra são de utilização
	# exclusiva para reuniões de comissões, das 8h30min às 19h.
	# O agendamento pode ser efetuado somente por pessoal lotado nas comissões permanentes, setor e seção de comissões
	# e que possuam permissão de operador de agenda
	def self.restricoes_comissoes?(evento)
		#5, 8,9 e 10 são ids das salas de comissões e de plenário ana terra		
		if [5,8,9,10].include?(evento.local_id)						
			hora_inicio = evento.horario_inicio.delete(":")
			dia_semana = evento.data_inicio.wday			
			if (dia_semana == 2) 				
				# tipo de evento 8 = reunião de comissão
				# tipo de evento 25 = reunião de comissão representativa				
				return true if ![8,25].include?(evento.tipo_evento_id) && hora_inicio.to_i <= 1900				
				#verificação se a solicitação parte de setores relacionados a comissões
				setores_responsaveis_ids =  evento.local.setores_responsaveis_ids.split(';')			
				return true if !setores_responsaveis_ids.include?(evento.setor_solicitante_id.to_s) && hora_inicio.to_i <= 1900
			else
				return false				
			end									
		end			
		return false
	end
	
	
end