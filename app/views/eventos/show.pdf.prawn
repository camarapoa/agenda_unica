pdf.font 'Helvetica'

# Dados do Evento

pdf.text "#{@evento.tipo_evento.nome} - #{@evento.titulo}"   , :size => 14, :style => :bold, :align => :left

evento_attributes = []
evento_attributes << ['Nome', @evento.titulo]
evento_attributes << ['Data', periodo(@evento)]
evento_attributes << ['Categoria', @evento.categoria]
evento_attributes << ['Descrição', @evento.descricao]
evento_attributes << ['Necessidades', @evento.observacao]
evento_attributes << ['Proponente', @evento.proponente]
evento_attributes << ['Coordenador', @evento.coordenador]
evento_attributes << ['Contato', @evento.contato]
evento_attributes << ['Processo', @evento.projeto]
evento_attributes << ['Documento', @evento.documento]

pdf.table evento_attributes,{
  :font_size => 8,
  :border_width   => 0,
  :align  =>        { 0 => :left, 1 => :left},
  :vertical_padding   => 1,
  :column_widths => { 0 => 100, 1 => 300 }}
  
pdf.move_down 10  

# Solicitações de recursos  

pdf.text "Solicitações de Recursos"   , :size => 12, :style => :bold, :align => :left
if @evento.recursos_alocados.size > 0
  pdf.table @evento.recursos_alocados.map{|r| [r.quantidade, r.recurso_evento.nome, r.observacao]}, {
      :font_size => 8,
      :headers       => ['Quantidade', 'Material', 'Observações'],
      :align_headers => { 0 => :left, 1 => :left, 2 => :left },
      :align         => { 0 => :left, 1 => :left, 2 => :left},
      :column_widths => { 0 => 75, 1 => 150, 2 => 300 }
    }
else  
  pdf.text "Não há solicitações de recursos paa este evento"
end

 pdf.move_down 10
# Histórico
pdf.text "Histórico", :size => 10, :style => :bold, :align => :left
pdf.text historico_to_pdf(@evento), :size => 7

pdf.text "\n\ndesenvolvido pela Assessoria de Informática - 2009", :size => 5, :style => :italic