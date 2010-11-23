class Comissao < ActiveRecord::Base
	
	set_table_name :legislativo_comissoes
	
	default_scope	:order => :sigla
	
	named_scope	:permanentes, :conditions => {:tipo => 'permanente'}
	
end