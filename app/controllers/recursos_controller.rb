class RecursosController < ApplicationController
  
  before_filter :cmpa_authenticate, :except => %w[ new historico_materiais agenda_projetor cadastrar ]
  
  def new
    @recurso_alocado = RecursoAlocado.new
    @evento = Evento.find(params[:evento_id])
    @evento.recursos_eventos.build
    setup
  end
  
  def create_solicitacao_mat
    @evento = Evento.find(params[:evento_id])
    @recurso_alocado = RecursoAlocado.new(params[:recurso_alocado]) { |ra| ra.evento = @evento }
    if @recurso_alocado.save
    	emprestimo = EmprestimoRecurso.new(
    		:recurso_evento_id => @recurso_alocado.recurso_evento.id, 
    		:data_inicio => @evento.data_inicio,
    		:horario_inicio => @evento.horario_inicio,
    		:data_termino => @evento.data_termino,
    		:horario_termino => @evento.horario_termino,
    		:quantidade => @recurso_alocado.quantidade,
    		:local => @evento.local.nome,
    		:setor_solicitante => @evento.setor_solicitante,
    		:created_by => current_user.id,
    		:updated_by => current_user.id    		
    	)
    	
    	emprestimo.save(false)    	
    	@recurso_alocado.update_attribute(:emprestimo_recurso_id, emprestimo.id)
      # Cria uma notificação de material solicitado
      log = LogEvento.create(:evento_id => @evento.id, :updated_by => current_user.nome,
        :history => {
          'material' => {
            'adicionado' => ["#{@recurso_alocado.quantidade}"],
            'item' => @recurso_alocado.recurso_evento.nome
          }
        })
      #envia_notificacao(log, 'adicao', @recurso_alocado, @evento)										  								
      
      flash[:message_material] = "<div class='notice'>Material solicitado com sucesso</div>"
      redirect_to new_evento_recurso_url(@evento)
    else
      setup
      render :new
    end
  end
  
  def edit_solicitacao_mat
    @recurso_alocado = RecursoAlocado.find(params[:recurso_id])    
    @evento = Evento.find(@recurso_alocado.evento)
    setup
  end
  
  def update_solicitacao_mat
    log_evento = RecursoAlocado.find(params[:recurso_id])
    log_evento.attributes = params[:recurso_alocado]
    
    @recurso_alocado = RecursoAlocado.find(params[:recurso_id])
    @evento = @recurso_alocado.evento
    
    if @recurso_alocado.update_attributes(params[:recurso_alocado])
      log = LogEvento.create(:evento_id => @evento.id, :updated_by => current_user.nome,
        :history => {
          'material' => {
            'alterado' => log_evento.changes,
            'item' => log_evento.recurso_evento.nome
          }
        })
      #envia_notificacao(log, 'alteracao', @recurso_alocado, @evento)	
      
      flash[:message_material] = "<div class='notice'>Material alterado com sucesso</div>"
      redirect_to new_evento_recurso_url(@evento)
    else
      setup
      render :new
    end
  end
  
  def destroy_solicitacao_mat
    @recurso_alocado = RecursoAlocado.find(params[:recurso_id])
    @evento = @recurso_alocado.evento
    
    # Cria uma notificação de material removido
    log = LogEvento.create(:evento_id => @evento.id, :updated_by => current_user.nome,
      :history => {
        'material' => {
          'removido' => ["#{@recurso_alocado.quantidade}", "#{@recurso_alocado.recurso_evento.nome}"]
        }
      })
    #envia_notificacao(log, 'remocao', @recurso_alocado, @evento)							
    
    @recurso_alocado.destroy
    setup
    redirect_to new_evento_recurso_path(@evento)
  end
  
  def historico_materiais
    @logs = Evento.find(params[:evento_id]).logs.all(:order => 'updated_at DESC')
    render :layout => false
  end
  
  def envia_convocacao
    @evento = Evento.find(params[:evento_id])
    @evento.recursos_eventos.build
    @recurso_alocado = RecursoAlocado.new
    setup
    responsavel = Pessoa.find(@evento.created_by).nome    
    recursos_eventos = params[:convocacoes] ? params[:convocacoes].map { |c_id| RecursoEvento.find(c_id) } : []
    
    if recursos_eventos.any?
      if enviar_emails recursos_eventos, @evento, 'convocacao', responsavel
        flash[:message_convocacao] = "<div class='notice'>Convocação realizada com sucesso</div>"
      else
        flash[:message_convocacao] = "<div class='error'>Problema no envio de convocação. Contate a assessoria de Informática (r. 4334)</div>"
      end
    else
      flash[:message_convocacao] = "<div class='warning'>Marque ao menos uma caixa de texto</div>"
    end
    
    redirect_to new_evento_recurso_path(@evento, :tab => @tab)
  end
  
  def envia_ciencia
    @evento = Evento.find(params[:evento_id])
    @evento.recursos_eventos.build
    @recurso_alocado = RecursoAlocado.new
    @materiais = RecursoEvento.materiais - @evento.recursos_eventos
    @materiais = @materiais.collect{|m| ["#{m.nome} (#{m.setor_responsavel.nome}) ", m.id]}
    @recursos_convocacoes = RecursoEvento.convocacoes
    @recursos_ciencias = RecursoEvento.ciencias
    responsavel = Pessoa.find(@evento.created_by).nome
    
    recursos_eventos = params[:ciencias] ? params[:ciencias].map { |c_id| RecursoEvento.find(c_id) } : []
    
    if recursos_eventos.any?
      a = enviar_emails recursos_eventos, @evento, 'ciencia', responsavel
      flash[:message_ciencia] = "<div class='notice'>Convocação realizada com sucesso</div>"
    else
      flash[:message_ciencia] = "<div class='warning'>Marque ao menos uma caixa de texto</div>"
    end
    
    redirect_to new_evento_recurso_path(@evento)
  end
  
  # Exibe os agendamentos do projetor multimídia para o mês do evento
  def agenda_projetor
    @evento = Evento.find(params[:evento_id])
    recurso_projetor = RecursoEvento.nome_matches('Projetor Multi%a').first
    @recursos_eventos = RecursoAlocado.all(:joins => :evento,
      :conditions => ['recurso_evento_id = ? and month(data_inicio) = ? and year(data_inicio) = ? and status <> ? ',
                     recurso_projetor.id, @evento.data_inicio.month, @evento.data_inicio.year, 'cancelado'])
    render :layout => 'projetor'
  end
  
  def verifica_disponibilidade_item
    quantidade = RecursoEvento.itens_disponiveis(Evento.find(params[:evento_id]), params[:recurso_evento_id])
    render :text => quantidade  	
  end
  
  private
  
    def setup
      @materiais = RecursoEvento.materiais - @evento.recursos_eventos
      @materiais_indisponiveis = RecursoEvento.materiais_indisponiveis      
      @materiais = @materiais.map { |m| ["#{m.nome} ( Disponíveis: #{(RecursoEvento.itens_disponiveis(@evento,m.id) >= 0) ? RecursoEvento.itens_disponiveis(@evento,m.id) : 'a verificar'  } item(s) )  ", m.id] }
      @recursos_convocacoes = RecursoEvento.convocacoes
      @recursos_ciencias = RecursoEvento.ciencias
      @logs = @evento.logs.all(:order => 'updated_at DESC')
    end
  
    # Envia um email para cada um dos emails do recurso, devidamente
    # separados por ponto-e-vírgula
    def enviar_emails(recursos, evento, tipo_convocacao, responsavel)
      recursos.each do |recurso|
        unless recurso.emails.blank?
          emails = recurso.emails.split(';')
          return false if !enviar_email evento, emails, tipo_convocacao, responsavel        
        end
      end
      convocados = recursos.collect{|recurso| "#{recurso.nome} - #{recurso.emails}"}.sort
      LogEvento.create(:history => { 'emails' => convocados }, :evento_id => evento.id, :updated_by => current_user.nome)
    end
    
    # Envia um email personalizado dependendo do tipo de convocação
    def enviar_email(evento, emails, tipo_convocacao, responsavel)
      begin
      	
      	emails << "chuvisco@camarapoa.rs.gov.br"
    	
        case tipo_convocacao
          when 'ciencia' then email = EventoMailer.create_envia_confirmacao_ciencia(evento, emails, responsavel)
          when 'convocacao' then email = EventoMailer.create_envia_confirmacao_convocacao(evento, emails, responsavel)
        end

        email.set_content_type 'text/html'
        EventoMailer.deliver email
        
        
      rescue Exception => e
      	 new_file = File.open('erro_convocacao.txt','wb')    
    		 new_file.write(e)
    		 new_file.close()				
        return false
      end
      true
    end
    
    def envia_notificacao(log, operacao, recurso_alocado, evento)  	
      changes = log.history['material']
      nome_material = changes['item']
      texto = ""
      if operacao == 'alteracao'  		
        alteracoes = changes['alterado']
        texto = "<ul>"
        alteracoes.each do |key,value|
          texto += "<li>#{nome_material.capitalize}: <b>#{key}</b> alterada de <b>#{value[0]}</b> para <b>#{value[1]}</b> <i>(alterado por #{log.updated_by}, em #{log.updated_at.strftime('%d/%m/%Y às %H:%M:%S')}</i>)</li>"  			
        end
        texto += "</ul>"						
      elsif operacao == 'remocao'  
        texto += "Removida a solicitação de <b>#{changes['removido'][0]} #{changes['removido'][1]}</b>  <i>( por #{log.updated_by}, em #{log.updated_at.strftime('%d/%m/%Y às %H:%M:%S')}</i>)"
      else	
        texto += "Acrescentada  a solicitação de <b>#{changes['adicionado'][0]} #{changes['item']}</b>  <i>( por #{log.updated_by}, em #{log.updated_at.strftime('%d/%m/%Y às %H:%M:%S')}</i>)"							
      end 						
        
      #emails = recurso_alocado.recurso_evento.emails.split(';') if recurso_alocado.recurso_evento.emails.include?(';')
       
      email = EventoMailer.create_envia_notificacao_solicitacao_recurso(evento, texto, emails)
      email.set_content_type 'text/html'
      EventoMailer.deliver email
    end
  
end