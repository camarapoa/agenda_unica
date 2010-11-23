class ApplicationController < ActionController::Base

  helper :all
  helper_method :operador?, :back_path_or, :alteracao_evento_permitida?
  filter_parameter_logging :password

  before_filter :change_codepage, :store_location

  LOGGER_DESTROY = Logger.new("#{RAILS_ROOT}/log/eventos_excluidos.log")

  def parse_textile
    render :text => RedCloth.new(params[:data]).to_html
  end

  def store_location
    if request.request_method == :get && session[:last] != request.request_uri
      session[:back_path] = session[:last]
      session[:last] = request.request_uri
    end
  end

  def back_path_or(default)
    session[:back_path] || default
  end
  
  # Para alterar dados de um evento, um desses critérios deve ser verdadeiro
  # 1. o usuário logado é administrador da agenda unica
  # 2. o usuário logado é operador da agenda única eo setor da lotação temporária é o mesmo setor do solicitante
  def alteracao_evento_permitida?(evento)
  	return true if current_lotacao.role_of_administrador_agenda?
  	if current_lotacao.role_of_operador_agenda?
  		return true if current_lotacao.setor.id == evento.setor_solicitante_id
  	end
  	return false	  	
	end
	
	def funcionario_operador?
	end


  private

    def operador?
      return false if !current_user
      current_lotacao.in_groups_of_operador_agenda?
    end

    def change_codepage
      WIN32OLE.codepage = WIN32OLE::CP_UTF8 if defined? WIN32OLE
    end

end


