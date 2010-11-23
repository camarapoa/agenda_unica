pdf.font 'Helvetica'
pdf.text "Agenda Única - Eventos do dia #{@day}/#{@month}/#{@year} (ordenados por categoria)\n\n", :size => 13 


if @hash_eventos.size > 0
	@hash_eventos.each do |categoria, eventos| 
		hash_horarios = eventos.group_by(&:horario_inicio)
		pdf.text categoria, :size => 11
		pdf.move_down 15
		pdf.bounding_box [10,pdf.cursor], :width => 500 do
			hash_horarios.each do |horario, eventos_horario|
				pdf.text(horario, :size => 9) 
				pdf.bounding_box [30,pdf.cursor], :width => 500 do				
					for evento in eventos_horario 		
           	local = "#{evento.local.nome}" if evento.local
						local = evento.outro_local if !evento.local
 
						texto = "#{evento.tipo_evento.nome} - #{evento.titulo} (#{evento.local.nome})"
					  pdf.text(texto, :size => 8)
					end
				end
				pdf.move_down 15
			end
		end
	end
else
	pdf.text "Nenhum evento encontrado"
end


pdf.move_down 15
pdf.stroke_horizontal_rule
pdf.move_down 10
pdf.text "impresso em  #{Time.now.strftime('%d/%m/%Y,às %H:%M:%S')}", :size => 7, :style => :italic


