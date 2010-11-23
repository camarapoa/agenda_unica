class EmprestimosController < ApplicationController
	
	before_filter :cmpa_authenticate	
	
	def index
		ativos  = Emprestimo.ativos
		@emprestimos = ativos.por_atender	
		@emprestimos += ativos.autorizados_por_superior
		@emprestimos_aguardando_autorizacao_superior = ativos.aguardando_autorizacao_superior
		@ultimas_solicitacoes = Emprestimo.encerrados.limit(100)	
	end
	
	def new
		@tipos_eventos = TipoEvento.all
	end	
	
	def edit
		@emprestimo = Emprestimo.find(params[:id])		
		@tipos_eventos = TipoEvento.all		
	end	

	def update		
		@emprestimo = Emprestimo.find(params[:id])					
		@emprestimo.updated_by = @emprestimo.funcionario_autorizador_id = current_user.id
		
		if params[:commit] == 'autorizacao_superior'	
			@emprestimo.status = 'autorizado_por_superior'
			@emprestimo.autorizacao_super_em = Time.now
			@emprestimo.super_id = current_user.id									
		end		
				
		if params[:commit] == 'solicitar_autorizacao_superior'	
			@emprestimo.status = 'aguardando_autorizacao_superior' 			
		end
		
		if params[:commit] == 'negar' || params[:commit] == 'negativa_superior'		
			@emprestimo.status = 'nao_autorizado' 			
		end		
		
    if @emprestimo.update_attributes(params[:emprestimo])
      flash[:notice] = 'Negativa Registrada com Sucesso!'  if params[:commit] == 'negar'  || params[:commit] == 'negativa_superior'
      flash[:notice] = 'Autorização Registrada com Sucesso!'  if params[:commit] == 'autorizacao_superior'
      notifica(@emprestimo, 'nao_autorizado') if params[:commit] == 'negar'      
      notifica(@emprestimo, 'negativa_superior') if params[:commit] == 'negativa_superior'   
      notifica(@emprestimo, 'autorizacao_por_superior') if params[:commit] == 'autorizacao_superior'            
      flash[:notice] = 'Solicitação enviada com sucesso!'  if params[:commit] == 'solicitar_autorizacao_superior'  
      notifica(@emprestimo, 'para_autorizacao_superior') if params[:commit] == 'solicitar_autorizacao_superior'            
      redirect_to emprestimos_path
    else    	
      render params[:commit]
    end
	end	
	
	def autorizar
		@emprestimo = Emprestimo.find(params[:id])
		begin
			@emprestimo.transaction do
				evento = Evento.new
				evento.contato = @emprestimo.contato
				evento.proponente = @emprestimo.proponente
				evento.categoria = @emprestimo.categoria
				evento.tipo_evento_id = @emprestimo.tipo_evento_id
				evento.titulo = @emprestimo.tipo_evento.nome
				evento.descricao = @emprestimo.descricao
				evento.data_inicio = @emprestimo.data_inicio
				evento.horario_inicio = @emprestimo.horario_inicio
				evento.data_termino = @emprestimo.data_termino
				evento.horario_termino = @emprestimo.horario_termino
				evento.local_id = @emprestimo.espaco_id
				evento.status = 'confirmado'
				evento.created_by = @emprestimo.funcionario_solicitante_id
				evento.updated_by = current_user.id
				evento.setor_solicitante_id = @emprestimo.setor_solicitante_id
				evento.setor_gerente_id = @emprestimo.setor_solicitante_id
				evento.observacao = @emprestimo.necessidades
				evento.save(false)	
			  # redundancia deida ao before_create
				evento.status = 'confirmado'
				evento.save(false)					
				@emprestimo.evento_id = evento.id
				@emprestimo.status = 'atendido'		
				@emprestimo.funcionario_autorizador_id = current_user.id
				@emprestimo.save(false)		
			end			
			flash[:notice] = "Solicitação autorizada com sucesso!"
			redirect_to emprestimos_path
		rescue Exception => e		
			f = File.new('emprestimo.txt', 'wb')	
			f.write(e)
			f.close()
			raise ActiveRecord::Rollback, "Problemas na autorização. Contate a Assessoria de Informática (Ramal 4334)."
		end		
	end		
	
	def gerenciar
		@emprestimo = Emprestimo.find(params[:id])
		begin
			@emprestimo.transaction do
				evento = Evento.new
				evento.contato = @emprestimo.contato
				evento.proponente = @emprestimo.proponente
				evento.categoria = @emprestimo.categoria
				evento.tipo_evento_id = @emprestimo.tipo_evento_id
				evento.descricao = @emprestimo.descricao
				evento.data_inicio = @emprestimo.data_inicio
				evento.horario_inicio = @emprestimo.horario_inicio
				evento.data_termino = @emprestimo.data_termino
				evento.horario_termino = @emprestimo.horario_termino
				evento.local_id = @emprestimo.espaco_id								
				evento.updated_by = current_user.id
				evento.setor_solicitante_id = @emprestimo.setor_solicitante_id
				evento.created_by = current_user.id
				evento.setor_gerente_id = current_lotacao.setor_id
				evento.observacao = @emprestimo.necessidades
				evento.save(false)			
				# redundancia deida ao before_create
				evento.status = 'confirmado'
				evento.save(false)			
				@emprestimo.evento_id = evento.id
				@emprestimo.status = 'atendido'		
				@emprestimo.funcionario_autorizador_id = current_user.id
				@emprestimo.save(false)		
			end			
			flash[:notice] = "Gerenciamento registrado com sucesso!"
			redirect_to new_evento_recurso_path(@emprestimo.evento_id)
		rescue Exception => e						
			raise ActiveRecord::Rollback, "Problemas na autorização. Contate a Assessoria de Informática (Ramal 4334).\n #{e}"
		end
	end
	
	
	def show
		@emprestimo = Emprestimo.find(params[:id])	
	end
	
	def negar
		@emprestimo = Emprestimo.find(params[:id])
	end		
	
	def solicitar_autorizacao_superior
		@emprestimo = Emprestimo.find(params[:id])
	end		
	
	def negativa_superior
		@emprestimo = Emprestimo.find(params[:id])
	end

	def autorizacao_superior
		@emprestimo = Emprestimo.find(params[:id])
	end	
	
	
	def notifica(emprestimo, acao)			
		if acao == 'nao_autorizado' || acao == 'negativa_superior'
			emails = emprestimo.funcionario_solicitante.email
			email = EmprestimoMailer.create_envia_notificacao_nao_autorizacao_solicitacao(emprestimo, emails)  									
		end			
		if acao == 'para_autorizacao_superior'	
			#emails para solicitante e administradores superiores
			emails = GrupoAcesso.find_by_mascara('SUPER_ADMINISTRADOR_AGENDA').lotacoes_temporarias.collect{|l| l.pessoa}.collect{|p| p.email}  << emprestimo.funcionario_solicitante.email
			email = EmprestimoMailer.create_envia_notificacao_para_autorizacao_superior(emprestimo, emails)  									
		end	
		if acao == 'autorizado_por_superior'	
			#emails para solicitante e administradores superiores
			emails = GrupoAcesso.find_by_mascara('ADMINISTRADOR_AGENDA').lotacoes_temporarias.collect{|l| l.pessoa}.collect{|p| p.email}  << emprestimo.funcionario_solicitante.email
			email = EmprestimoMailer.create_envia_notificacao_autorizado_por_superior(emprestimo, emails)  									
		end	
		
		begin
	    email.set_content_type 'text/html'
	    EmprestimoMailer.deliver email
		rescue Exception => e	
		end		
	end		
	
	
end