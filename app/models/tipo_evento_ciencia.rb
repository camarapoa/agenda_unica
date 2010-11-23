class TipoEventoCiencia < ActiveRecord::Base

  belongs_to :setor
  
  set_table_name :agenda_tipos_eventos_ciencias
  
end