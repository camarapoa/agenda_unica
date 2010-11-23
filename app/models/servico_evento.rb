class ServicoEvento < ActiveRecord::Base
	
	belongs_to	:servico
	belongs_to	:evento
	
end