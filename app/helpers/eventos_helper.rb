module EventosHelper
  
  def setup_evento(evento)
    evento.tap { |e| e.assets.build if evento.assets.none? { |asset| asset.new_record? } }
  end
  
  def origem_evento(evento)
		return "Este evento foi originado por #{evento.emprestimo.funcionario_solicitante.nome}, do(a) #{evento.emprestimo.setor_solicitante.nome}" if evento.emprestimo.present?
		return "Este evento foi originado por #{evento.setor_solicitante.nome}, de) #{Pessoa.find(evento.created_by).nome}" if evento.setor_solicitante.present?
		return "Este evento foi originado por #{Pessoa.find(evento.created_by).nome}" if !evento.setor_solicitante.present?
	end
	
end