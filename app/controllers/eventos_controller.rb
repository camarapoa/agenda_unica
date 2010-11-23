class EventosController < ApplicationController
  
  before_filter :cmpa_authenticate, :except => %w[ index historico buscar_processos buscar_eventos impressao ]
  before_filter :store_eventos_uri, :only => :index
  
  def index    
    params[:day], params[:month], params[:year] = params[:evento][:data_inicio].split('/') if params[:evento]
    params[:day]   ||= Time.now.day
    params[:month] ||= Time.now.month
    params[:year]  ||= Time.now.year
    
        
    @data_busca = FormattedDate::Conversion.to_datetime([params[:day], params[:month], params[:year]].join('/'))
    @evento = Evento.new(params[:evento] || { :data_inicio => @data_busca })
    
    @eventos = Evento.search(@evento).all(:order => 'horario_inicio')
    @emprestimos_espacos = Emprestimo.ativos.por_atender #nem todo ativo está por atender

    @hash_eventos = @eventos.group_by { |h| h.tipo_evento.categoria }
    @tipos_eventos = TipoEvento.all
    
    respond_to do |format|
      format.html
      format.pdf do
        if %w[ por_dia por_categoria ].include? params[:tipo_relatorio]
          render params[:tipo_relatorio], :layout => false
        end
      end
    end
  end

  def show
    @evento = Evento.find(params[:id])
    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def new
    @evento = Evento.new
    @tipos_eventos = TipoEvento.all
    @locais = Local.autorizados_para_usuario(current_lotacao.setor.id).collect{|l|["#{l.nome} ( #{l.complemento} )",l.id]}    
    @comissoes = Comissao.permanentes.collect{|c|["#{c.sigla} ( #{c.nome} )",c.id]}      
    session[:last_page] = request.env['HTTP_REFERER']
  end

  def create
    @evento = Evento.new(params[:evento])
    @evento.updated_by = @evento.created_by = current_user.id
    @evento.setor_solicitante_id = current_lotacao.setor.id   
    @evento.setor_gerente_id = current_lotacao.setor.id    
    if @evento.save
      flash[:message] = "<div class='notice'>Evento registrado com sucesso</div>"
      redirect_to new_evento_recurso_url(@evento, :tab => 0)
    else
      @tipos_eventos = TipoEvento.all      
      @comissoes = Comissao.permanentes.collect{|c|["#{c.sigla} ( #{c.nome} )",c.id]}      
      @locais = Local.autorizados_para_usuario(current_lotacao.setor.id).collect{|l|["#{l.nome} ( #{l.complemento} )",l.id]}
      render :new
    end
  end

  def edit
    @evento = Evento.find(params[:id])
    @tipos_eventos = TipoEvento.all
    @locais = Local.autorizados_para_usuario(current_lotacao.setor.id).collect{|l|["#{l.nome} ( #{l.complemento} )",l.id]}
    @comissoes = Comissao.permanentes.collect{|c|["#{c.sigla} ( #{c.nome} )",c.id]}      
    session[:last_page] = request.env['HTTP_REFERER']
  end

  def update
    @evento = Evento.find(params[:id])
    @evento.updated_by = current_user.id
    
    if @evento.update_attributes(params[:evento])
      flash[:notice] = "Evento alterado com sucesso"      
      redirect_to new_evento_recurso_url(@evento, :tab => 0) and return if params[:save_and_close]
      redirect_to edit_evento_url(@evento)
    else
      @tipos_eventos = TipoEvento.all      
      @locais = Local.autorizados_para_usuario(current_lotacao.setor.id).collect{|l|["#{l.nome} ( #{l.complemento} )",l.id]}
      @comissoes = Comissao.permanentes.collect{|c|["#{c.sigla} ( #{c.nome} )",c.id]}      
      render :edit
    end
  end

  def destroy
    evento = Evento.find(params[:id])
    logs_evento = LogEvento.find_all_by_evento_id(evento)
    logs_evento.each(&:destroy) if logs_evento
    evento.destroy
    redirect_to eventos_url
  end
  
  def destroy_asset
    evento = Evento.find(params[:id])
    asset = evento.assets.find(params[:asset_id])
    asset.destroy
    redirect_to edit_evento_url(evento)
  end

  def cancelar
    evento = Evento.find(params[:id])
    evento.cancelar!
    redirect_to new_evento_recurso_url(evento, :tab => 0)
  end

  def confirmar
    evento = Evento.find(params[:id])
    evento.confirmar!
    redirect_to new_evento_recurso_url(evento, :tab => 0)
  end

  def historico
    @logs = LogEvento.find_all_by_evento_id(params[:id], :order => 'updated_at DESC')
  end

  def buscar_processos
   @processos = if params[:processo].present?
      processo, ano = params[:processo].split('/')
      processo = processo.strip
      scope = Projeto.numero_like(processo)
      scope = scope.ano_like(ano) if ano.present?
      scope.all(:order => 'ano, numero')
    else
      []
    end
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  def buscar_eventos  	
  	@evento = Evento.new(params[:evento])
  	@tipos_eventos = TipoEvento.all
  	@eventos = []
  	@hash_eventos = []
  	if @evento.periodo_valido?
  		@eventos = Evento.search(@evento).all(:order => 'data_inicio, horario_inicio')  
  		@hash_eventos = @eventos.group_by { |h| h.data_inicio }  	
  		
  		#@hash_eventos = @eventos.group_by { |h| h.tipo_evento.categoria }
  	else  		
  		render :action => :index  		
  	end	
	end
	
	def impressao		
  	@evento = Evento.new(params[:evento])
		@eventos = Evento.search(@evento).all(:order => 'data_inicio, horario_inicio')  		
		respond_to do |format|
      format.pdf { render :layout => false }
    end
	end
	
	def meus_eventos						
		#@meus_eventos = Evento.ativos.por_owner(current_lotacao.setor_id).paginate(:page => params[:page])		
		@meus_eventos = Evento.ativos.por_owner(current_lotacao.setor_id)		
	end	
  
  private
  
    def store_eventos_uri
      unless request.format.pdf?
        session[:eventos_uri] = request.request_uri
      end
    end
  
end