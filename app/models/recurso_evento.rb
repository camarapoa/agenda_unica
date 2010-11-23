class RecursoEvento < ActiveRecord::Base
    
  belongs_to :setor_responsavel, :class_name => 'Setor', :foreign_key => :setor_responsavel_id
  has_many   :recursos_alocados
  has_many   :emprestimos, :class_name => 'EmprestimoRecurso'
  
  set_table_name :agenda_recursos_eventos
  
  default_scope :order => 'nome'
  named_scope   :materiais, :conditions => ["tipo = 'material' AND quantidade > 0"]
  named_scope   :materiais_indisponiveis, :conditions => ["tipo = 'material' AND (quantidade = 0 OR quantidade IS NULL)"]
  named_scope   :convocacoes, :conditions => { :tipo => 'convocacao' }, :include => :setor_responsavel
  named_scope   :ciencias, :conditions => { :tipo => 'ciencia' }, :include => :setor_responsavel, :order => 'setores.nome'
  named_scope   :nome_matches, lambda { |match| { :conditions => ['nome like ?', match] } }
  
  #
  # Cada material possui uma quantidade e essa quantidade deve estar disponível
  # na data e horário do evento.
  #
  def self.itens_disponiveis(evento, recurso_evento_id)
    recurso_evento = find(recurso_evento_id)
    emprestimos = recurso_evento.emprestimos.find_all_by_data_inicio(evento.data_inicio)  
    
    total = recurso_evento.quantidade || 0
    return total if emprestimos.none?
    
    intervalos_solicitados = time_intervals(evento.horario_inicio, evento.horario_termino, 5)
    emprestimos.inject(total) do |disponivel, emprestimo|    	
      intervalos_emprestimos = time_intervals(emprestimo.horario_inicio, emprestimo.horario_termino, 5)    
      disponivel -= emprestimo.quantidade if (intervalos_solicitados & intervalos_emprestimos).any?
      disponivel
    end    
  end    
  
  # períodos inicial e final no formato "yyyymmdd HH:MM"		
  def self.quantidade_disponivel(recurso, periodo_inicial, periodo_final)   	  	
  	intervalos_solicitados = UtilDate.date_time_intervals(periodo_inicial, periodo_final, 5)	
  	#y periodo_inicial
  	#y periodo_final	
  	emprestimos = EmprestimoRecurso.emprestados.concomitantes(periodo_inicial.to_datetime, periodo_final.to_datetime).por_recurso(recurso.id)
  	#y "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  	#y "emprestmo encontrados #{emprestimos.size}"
  	#y emprestimos.first if emprestimos.size == 1
  	
  	#y "emprestimos empty$$$$$$$" if emprestimos.empty?
  	
  	return recurso.quantidade if emprestimos.empty?
  	return recurso.quantidade - emprestimos.first.quantidade if emprestimos.size == 1
  	
  	conjuntos = []
  	interseccoes = []
  	quantidade_emprestada = 0
  	ids_solicitacoes = []
  	
  	emprestimos.each do |e|  		
  		conjuntos << [e.id, "#{e.data_inicio.strftime('%Y%m%d')} #{e.horario_inicio}", "#{e.data_termino.strftime('%Y%m%d')} #{e.horario_termino}"]	
  	end  	  	  	
  	
  	#y "ooooooooooooooooooooooooooooooooooooooooo"
  	
  	until conjuntos.empty?
  		periodo = conjuntos.pop
  		intervalos_periodo = UtilDate.date_time_intervals(periodo[1], periodo[2], 5)
  		#y "comparando #{periodo} com demais"
  		conjuntos.each do   |elemento|
  			intervalos_comp = UtilDate.date_time_intervals(elemento[1], elemento[2], 5)
  			sobreposicao = intervalos_periodo & intervalos_comp
  			if !sobreposicao.empty?
  				sobreposicao.push(periodo[0])
  				sobreposicao.push(elemento[0])  				
  				quantidade_emprestada += EmprestimoRecurso.find(periodo[0]).quantidade if !ids_solicitacoes.include?(periodo[0])
  				quantidade_emprestada += EmprestimoRecurso.find(elemento[0]).quantidade if !ids_solicitacoes.include?(elemento[0])
  				ids_solicitacoes << periodo[0] 
  				ids_solicitacoes << elemento[0]
  				ids_solicitacoes.uniq!  				
  				#y "ids solicitacoes => #{ids_solicitacoes}"
  				#y "quantidade emprestda primeira etapa = #{quantidade_emprestada}"
  				#y "sobreposicao => #{sobreposicao}"  				
  				interseccoes << sobreposicao
  			else
  				#nenhum dos intervalos das solicitações existentes se intersecciona
  				#necessário testar a nova solicitação com os próprios intervalos já solicitados
  				#y "sem sobre posicao"	
  				quantidade_emprestada = eval emprestimos.collect{|e| e.quantidade}.join('+')
  				#y "HHHHHHHHHHHH"
  				#y quantidade_emprestada
  				return (quantidade_emprestada >= recurso.quantidade) ? 0 : (recurso.quantidade - quantidade_emprestada)
				end  			
  		end	  	
		end
		#y "----------------------"
  	#y "----------------------" 	
  	#y interseccoes
  	#y "----------------------"
  	#y "----------------------" 	
  			
		until interseccoes.empty?
			periodo_interseccao = interseccoes.pop
			#y "periodo inter #{periodo_interseccao}"
			first_id_periodo_interseccao = periodo_interseccao.pop
			second_id_periodo_interseccao = periodo_interseccao.pop			
			#y "comparando #{periodo_interseccao} com demais"
			#y "firt id => #{first_id_periodo_interseccao}"
			#y "second id => #{second_id_periodo_interseccao}"
			#y "inter apos pop => #{interseccoes}"
			interseccoes.each do |p|
				first_id_p   =  p.last
				second_id_p  = 	p[p.length-2]
				paux = p[0..(p.length-3)]		
				#y "inter apos p  pop => #{interseccoes}"		
				#y "first p => #{first_id_p}"											
				#y "second p => #{second_id_p}"											
				sobreposicao = periodo_interseccao & paux		
				#y "sobre ---"		
				#y "-- periodo interseccao----"
				#y periodo_interseccao
				#y "---- p"
				#y paux
				
				#y "sobreposicao => #{sobreposicao}" if !sobreposicao.empty?
				#y "sem p sobreposicao" if sobreposicao.empty?
				if !sobreposicao.empty?
					quantidade_emprestada += EmprestimoRecurso.find(first_id_periodo_interseccao).quantidade if !ids_solicitacoes.include?(first_id_periodo_interseccao)
					quantidade_emprestada += EmprestimoRecurso.find(second_id_periodo_interseccao).quantidade if !ids_solicitacoes.include?(second_id_periodo_interseccao)
					quantidade_emprestada += EmprestimoRecurso.find(first_id_p).quantidade if !ids_solicitacoes.include?(first_id_p)
					quantidade_emprestada += EmprestimoRecurso.find(second_id_p).quantidade if !ids_solicitacoes.include?(second_id_p)
				end
				
				ids_solicitacoes << first_id_periodo_interseccao
				ids_solicitacoes << second_id_periodo_interseccao
				ids_solicitacoes << first_id_p
				ids_solicitacoes << second_id_p
				
				ids_solicitacoes.uniq!		
			end					
		end 	
		
		#y "ids => #{ids_solicitacoes}"
		#y "quantidade emprestada => #{quantidade_emprestada}"
		return recurso.quantidade - quantidade_emprestada
	end  
    
  
  private
  
    def self.time_intervals(begin_time, end_time, min_interval = 30)
      curr_time = Time.parse(begin_time)
      finish_time  = Time.parse(end_time)
      
      finish_time += 1.day if finish_time.hour < curr_time.hour
      
      intervals = []
      while curr_time <= finish_time
        intervals << curr_time.strftime('%H:%M')
        curr_time += min_interval.minutes
      end
      intervals
    end
end