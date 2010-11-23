pdf.font 'Helvetica'
pdf.text "Agenda Única - Eventos de #{@evento.data_inicio} a #{@evento.data_termino}\n\n", :size => 13


if @eventos.size > 0
pdf.table @eventos.map{|r| ["#{r.data_inicio}", "#{r.horario_inicio} - #{r.horario_termino}", "#{r.tipo_evento.nome} - #{r.titulo}", "#{r.local.present? ? "#{r.local.nome} - #{r.local.complemento}" : r.outro_local }"]}, {
      :font_size => 8,     
      :row_colors => ["FFFFFF", "EAEAEA"], 
      :border_style => :underline_header,
      :border_width => 0.5,
      :vertical_padding	=> 1,
      :headers       => ['Data', 'Horário', 'Evento', 'Local'],
      :align_headers => { 0 => :left, 1 => :left, 2 => :left, 3 => :left },
      :align         => { 0 => :left, 1 => :left, 2 => :left, 3 => :left},
      :column_widths => { 0 => 60, 1 => 60, 2 => 200, 3 => 200 }
}
else
pdf.text "Nenhum evento encontrado"
end

pdf.move_down 15
pdf.stroke_horizontal_rule
pdf.move_down 10
pdf.text "impresso em  #{Time.now.strftime('%d/%m/%Y,às %H:%M:%S')}", :size => 7, :style => :italic

 

    

    
    