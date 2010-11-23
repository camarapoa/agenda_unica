ActionController::Routing::Routes.draw do |map|
  
  map.parse_textile '/parse_textile', :controller => 'application', :action => 'parse_textile', :conditions => { :method => :post }
    
  map.connect '/eventos/buscar_processos', :controller => 'eventos', :action => 'buscar_processos'
  map.connect '/recursos/verifica_disponibilidade_item', :controller => 'recursos', :action => 'verifica_disponibilidade_item'
  map.connect '/eventos/buscar_eventos', :controller => 'eventos', :action => 'buscar_eventos'
    
  map.impressao '/eventos/impressao', :controller => 'eventos', :action => 'impressao'
  
  map.destroy_asset '/eventos/:id/destroy_asset/:asset_id', :controller => 'eventos', :action => 'destroy_asset', :conditions => { :method => :delete }
  map.meus_eventos '/eventos/meus_eventos', :controller => 'eventos', :action => 'meus_eventos'
  map.resources :eventos, :has_many => [:servicos, :recursos], 
                          :member => { :cancelar => :put, :confirmar => :put, :historico => :get }
	map.resources	:emprestimos, :member => { :negar => :put, 
																					 :autorizar => :put,
																					 :gerenciar => :put, 
																					 :solicitar_autorizacao_superior => :put,
																					 :negativa_superior => :put,
																					 :efetuar_negativa_superior => :put,
																					 :autorizacao_superior => :put, 
																					 :efetuar_autorizacao_superior => :put
																				  }                          
  
  map.with_options :controller => 'recursos', :path_prefix => '/recursos' do |recursos|
    recursos.agenda_projetor         '/agenda_projetor/:evento_id',          :action => 'agenda_projetor'
    recursos.create_solicitacao_mat  '/create_solicitacao_mat/:evento_id',   :action => 'create_solicitacao_mat'
    recursos.destroy_solicitacao_mat '/destroy_solicitacao_mat/:recurso_id', :action => 'destroy_solicitacao_mat'
    recursos.edit_solicitacao_mat    '/edit_solicitacao_mat/:recurso_id',    :action => 'edit_solicitacao_mat'
    recursos.update_solicitacao_mat  '/update_solicitacao_mat/:recurso_id',  :action => 'update_solicitacao_mat'
    recursos.historico_materiais     '/historico_materiais/:evento_id',      :action => 'historico_materiais'
    recursos.envia_convocacao        '/envia_convocacao/:evento_id',         :action => 'envia_convocacao'
    recursos.envia_ciencia           '/envia_ciencia/:evento_id',            :action => 'envia_ciencia'
  end
  
  map.root :controller => 'eventos'
end