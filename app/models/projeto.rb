#
# Esta é uma versão somplificada do modelo projeto, apenas para ser utilizada na agenda.
#
class Projeto < ActiveRecord::Base
  
  set_table_name :processos
	
  #PROJECT_PATH = "//cmpa_bkp2/DADOS/projetos/"
  PROJECT_PATH = "//cmpa-s02/wwwroot/processo_eletronico/"
  POSSIBLE_CONTENT_TYPES = Set.new ['application/msword','text/plain', 'application/octet-stream','application/vnd.ms-excel']
  ACTIVE_PRINTER = "PDFConverter"
#     GS_INST = "C:/gs/gs8.53/ps2pdf"
#     GS_INST = "C:\\gs\\gs8.53\\lib\\ps2pdf"
    GS_INST = "C:\\gs854\\gs8.54\\lib\\ps2pdf"
    
  named_scope :numero_like, lambda { |numero| { :conditions => ['numero LIKE ?', "%#{numero}%"] } }
  named_scope :ano_like, lambda { |ano| { :conditions => ['ano LIKE ?', "%#{ano}%"] } }

	def get_folder_name(processo)
  	return "#{processo.numero}#{processo.ano}#{processo.sigla}"
	end
end