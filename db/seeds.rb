class Object
  def with(obj)
    yield(obj)
  end
end

def nome_like(query)
  Setor.first(:conditions => ['nome LIKE ?', "%#{query}%"])
end

require 'win32ole'
require 'faker'
require 'populator'

[TipoEvento, Local, Evento, RecursoEvento].each(&:destroy_all)
# WIN32OLE.codepage = WIN32OLE::CP_UTF8    

with TipoEvento do |te|
  te.create :nome => 'Ato Solene'
  te.create :nome => 'Agenda da Presidência'
  te.create :nome => 'Eventos de Vereadores'
  te.create :nome => 'Audiência Pública'    
  te.create :nome => 'Sessão Solene'
  te.create :nome => 'Sessão Solene Externa'
  te.create :nome => 'Sessão Ordinária'
  te.create :nome => 'Reunião de Comissão'
  te.create :nome => 'Exposição'
  te.create :nome => 'Plenária do Estudante'
  te.create :nome => 'Evento do Executivo Municipal'
  te.create :nome => 'Visita Orientada'
  te.create :nome => 'Câmara Vai à Escola'
  te.create :nome => 'Palestra'
  te.create :nome => 'Seminário'
  te.create :nome => 'Curso'
end

with Local do |local|
  local.with_options :complemento => 'CMPA', :endereco => 'Av. Loureiro da Silva, 255 - Bairro Centro - Porto Alegre/RS' do |l|
    l.create  :nome => 'Plenário Otávio Rocha',    :setor => nome_like('ass%rela%p%')
    l.create  :nome => 'Saguão Adel Carvalho',     :setor => nome_like('se%memorial')
    l.create  :nome => 'T Cultural Tereza Franco', :setor => nome_like('se%memorial')
    l.create  :nome => 'Avenida Clébio Sória',     :setor => nome_like('se%memorial')
    l.create  :nome => 'Plenário Ana Terra',       :setor => nome_like('ass%rel%p%')            
    l.create  :nome => 'Teatro Glênio Peres',      :setor => nome_like('ass%rel%p%')                   
    l.create  :nome => 'Salão Nobre',              :setor => nome_like('gab%presi%')                   
    l.create  :nome => 'Sala das Comissões (301)', :setor => nome_like('ass%rel%p%')                    
    l.create  :nome => 'Sala das Comissões (302)', :setor => nome_like('ass%rel%p%')
    l.create  :nome => 'Sala das Comissões (303)', :setor => nome_like('ass%rel%p%')                    
    l.create  :nome => 'Avenida Clébio Sória',     :setor => nome_like('ass%rel%p%')
  end
end

with RecursoEvento do |re|
  re.create  :nome => 'Projetor Multimídia',                      :tipo => 'material',   :setor_responsavel => nome_like('se%atend%ver')
  re.create  :nome => 'Mesa Desmontável',                         :tipo => 'material',   :setor_responsavel => nome_like('%setor%porta%')
  re.create  :nome => 'Cubo',                                     :tipo => 'material',   :setor_responsavel => nome_like('%setor%porta%')
  re.create  :nome => 'Assessoria de Imprensa',                   :tipo => 'convocacao', :setor_responsavel => nome_like('assess%comun%soc')
  re.create  :nome => 'Portaria',                                 :tipo => 'convocacao', :setor_responsavel => nome_like('%set%portar%')
  re.create  :nome => 'Copa',                                     :tipo => 'convocacao', :setor_responsavel => nome_like('se%serv%aux')
  re.create  :nome => 'Garçom',                                   :tipo => 'convocacao', :setor_responsavel => nome_like('%se%serv%aux%')
  re.create  :nome => 'SAVB',                                     :tipo => 'convocacao', :setor_responsavel => nome_like('%se%atend%vere%')
  re.create  :nome => 'Taquigrafia para Ordem de Oradores',       :tipo => 'convocacao', :setor_responsavel => nome_like('se%o%taqui')
  re.create  :nome => 'Taquigrafia para Apanhados Taquigráficos', :tipo => 'convocacao', :setor_responsavel => nome_like('se%o%taqui')
  re.create  :nome => 'Serviço de Segurança',                     :tipo => 'convocacao', :setor_responsavel => nome_like('serv%segu')
  re.create  :nome => 'Sonorização',                              :tipo => 'convocacao', :setor_responsavel => nome_like('se%sonoriza')
  re.create  :nome => 'Fotografia',                               :tipo => 'convocacao', :setor_responsavel => nome_like('labor%fotogr')
  re.create  :nome => 'Seção de Serviços Auxiliares',             :tipo => 'convocacao', :setor_responsavel => nome_like('se%serv%aux')
  re.create  :nome => 'TV Câmara',                                :tipo => 'convocacao', :setor_responsavel => nome_like('assess%inform')
  re.create  :nome => 'Rádio-Jornalismo',                         :tipo => 'convocacao', :setor_responsavel => nome_like('assess%inform')
  re.create  :nome => 'Setor de Manutenção',                      :tipo => 'convocacao', :setor_responsavel => nome_like('setor%manut')
  re.create  :nome => 'Diretoria Geral',                          :tipo => 'ciencia',    :setor_responsavel => nome_like('dir%ger')
  re.create  :nome => 'Setor de Comissões',                       :tipo => 'ciencia',    :setor_responsavel => nome_like('setor%comiss')
  re.create  :nome => 'Diretoria Legislativa',                    :tipo => 'ciencia',    :setor_responsavel => nome_like('dir%legisla')
end


horarios = %w( 09:00 10:30 13:30 14:45 16:00 17:00 18:00 18:30 19:30 20:00 21:00 22:00 )

Evento.populate 30 do |e|
  e.processo_id     = 1
  e.categoria       = Evento::CATEGORIAS
  e.tipo_evento_id  = TipoEvento.all.map(&:id)
  e.titulo          = Faker::Lorem.words(4)
  e.descricao       = Faker::Lorem.paragraph
  e.local_id        = Local.all.map(&:id)
  e.data_inicio     = Time.now
  e.horario_inicio  = horarios
  e.data_termino    = [Time.now + rand(12).hours]
  e.horario_termino = horarios
  e.proponente      = Faker::Name.name
  e.coordenador     = Faker::Name.name
  e.contato         = "(51) 9999-9999 - Fulano"
  e.status          = Evento::STATUS
  e.created_by      = 1
end



