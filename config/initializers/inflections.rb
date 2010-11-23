ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural     /al$/,  'ais'
  inflect.plural     /ao$/,  'oes'
  inflect.plural     /ão$/,  'ões'
  inflect.plural     /em$/,  'ens'
  inflect.plural     /r$/,   'res'
  inflect.plural     /el$/,  'eis'
  inflect.singular   /ais$/, 'al'
  inflect.singular   /oes$/, 'ao'
  inflect.singular   /ens$/, 'em'
  inflect.singular   /eis$/, 'el'
  inflect.singular   /res$/, 'r'
  
  inflect.irregular 'evento_servico', 'eventos_servicos'
  inflect.irregular 'EventoServico', 'EventosServicos'
  inflect.irregular 'tipo_evento_servico', 'tipos_eventos_servicos'
  inflect.irregular 'TipoEventoServico', 'TiposEventosServicos'
  inflect.irregular 'tipo_evento_ciencia', 'tipos_eventos_ciencias'
  inflect.irregular 'TipoEventoCiencia', 'TiposEventosCiencias'
  inflect.irregular 'local_servico', 'locais_servicos'
  inflect.irregular 'LocalServico', 'LocaisServicos'
  inflect.irregular 'recurso_evento', 'recursos_eventos'
  inflect.irregular 'RecursoEvento', 'RecursosEventos'
  inflect.irregular 'recurso_alocado', 'recursos_alocados'
  inflect.irregular 'RecursoAlocado', 'RecursosAlocados'
end