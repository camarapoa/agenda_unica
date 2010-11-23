module ApplicationHelper

  def select_elements(*elements)
    content_for(:select_elements) do
      elements.map { |e| "##{ e }" }.join(', ')
    end
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end

  # Retorna um HTML com as mensagens de flash em suas respectivas divs e ids.
  # O <tt>id</tt> é a chave do hash do parâmetro <tt>flash</tt>.
  def flash_messages(flash)
    flash.inject('') { |contents, (k, v)| contents + content_tag(:div, v, :class => "flash #{k}") }
  end

  def help_button(id)
    "<span id='help_#{id}'>#{image_tag 'help.png'}</span>"
  end

  def parse_textile(data)
    render :text => RedCloth.new(data).to_html
  end
  
  # Retorna um array de strings no formato especificado por <tt>options[:format]</tt>
  # no intervalo de <tt>start</tt> à <tt>finish</tt> em incrementos de <tt>options[:step]</tt>.
  # Exemplo: time_intervals '15:45', '19:30', :step => 20.minutes, :format => '%Hh %Mmin'
  def time_intervals(start, finish, options = {})
    options.reverse_merge! :step => 30.minutes, :format => '%H:%M'
    start, finish = DateTime.parse(start), DateTime.parse(finish)
    finish += 1.day if finish < start
    intervals = []
    start.step(finish, options[:step]) { |d| intervals << d.strftime(options[:format]) }
    intervals
  end

  def periodo(evento)
    return "em #{evento.data_inicio.strftime('%d/%m/%Y')}, das #{evento.horario_inicio} às #{evento.horario_termino}" if evento.data_inicio == evento.data_termino
    return "de #{evento.data_inicio.strftime('%d/%m/%Y')} a #{evento.data_termino.strftime('%d/%m/%Y')}, das #{evento.horario_inicio} às #{evento.horario_termino}"
  end

  def check_boxes_servicos(evento_id)
    servicos = Servico.find(:all, :order => :nome)
    aux = ""
    evento = Evento.find(evento_id)
    for servico in servicos
      checked = evento.servicos.include?(servico)
      aux << check_box_tag("evento[servicos][#{servico.id}]", checked, checked)
      aux << servico.nome + '<br/>'
    end
    return aux
  end

  def show_evento(evento,logged, seq)
    #seq é um numero sequencial, necesario devido a utilizacao do metodo evento.build_periodicos
    logged = true
    logged.present? ? (onclick = "onclick=\"edita('#{evento.id}')\")") : (onclick =  "")
    #tip = "<b>#{evento.titulo}</b><br/><br/><span style='font-size:11px'>#{periodo(evento)}</span><br/>#{evento.local.nome}<br/><br/><i>( evento #{evento.status}</i> )"
    link_to_edit = link_to "#{evento.horario_inicio} - #{evento.tipo_evento.nome}", new_evento_recurso_path(evento.id)
    "<div class='evento #{evento.past? ? 'past' : evento.status}' #{onclick}>#{link_to_edit}</div></div>"
    # <div id= 'evento_#{seq}_#{evento.id}' class='evento #{evento.status}'  #{onclick}>#{link_to_edit}</div>"
  end

  def timeline(month, year)
    months = ""
    12.times do |i|
      months << "<th>#{link_to I18n.t(:date)[:abbr_month_names][i+1], calendar_path(i+1,year)}</th>"
    end
    lines = "";   12.times { |i| lines << "<td #{"class='selected'" if month == i+1}><!-- --></td>" }
    %(
      <table class='timeline'>
        <tr>
          #{months}
        </tr>
        <tr>
          #{lines}
        </tr>
      </table>
    )
  end

  def show_text_or_indication(text, indication = 'Não Informado')
    text.blank? ? indication : text
  end

  def historico_to_pdf(evento)
    text = ''
    logs = evento.logs
    logs.each do |log|
      changes = log.history
      m = log.history['material']
      text += "\nAtualizado em #{log.updated_at.strftime('%d/%m/%Y')} às #{log.updated_at.strftime('%Hh %Mmin')} por #{log.updated_by}\n\t\t"
      if c = changes['emails']
        text += "Convocação/ciência enviada para os seguintes e-mails\n"
        c.each do |email|
          text += "\t\t\t\t#{email.downcase}\n"
        end
      end
      text += "\tData de início foi modificada de #{c[0]} para #{c[1]}\n" if c = changes['data_inicio']
      text += "\tHorario de início foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['horario_inicio']
      text += "\tData de término foi modificada de #{c[0]} para #{c[1]}\n" if c = changes['data_termino']
      text += "\tHorario de término foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['horario_termino']
      text += "\tLocal foi modificado de #{Local.find(c[0]).nome.to_s} (#{Local.find(c[0]).complemento.to_s}) para
            #{Local.find(c[1]).nome.to_s} (#{Local.find(c[1]).complemento.to_s})\n" if c = changes['local_id']
      text += "\tOutro local foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['outro_local']
      text += "\tTipo de evento foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['tipo_evento_id']
      text += "\tProcesso foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['processo_id']
      text += "\tTitulo  foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['titulo']
      text += "\tProponente  foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['proponente']
      text += "\tCoordenador  foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['coordenador']
      text += "\tContato  foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['contato']
      text += "\tDocumento  foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['documento']
      text += "\tStatus  foi modificado de #{c[0]} para #{c[1]}\n" if c = changes['status']

      if m
        if m['removido']
          text += "#{m['removido'][0]} #{m['removido'][1]} removidos(as)"
        elsif m['adicionado']
          text += "#{m['adicionado'][0]} #{m['item']} solicitados(as)"
        end

        if m['alterado']
          if m['quantidade']
            text += "Quantidade foi modificada de #{m['quantidade'][0]} para #{m['quantidade'][1]} unidades"
          end
          if m['observacao']
            if m['observacao'][0].blank?
              text += "Observação #{m['observacao'][1]} adicionada"
            elsif m['observacao'][1].blank?
              text += "Observação #{m['observacao'][0]} removida"
            else
              text += "Observação foi modificada de #{m['observacao'][0]}  para #{m['observacao'][1]}"
            end
          end
          if m['recurso_evento_id']
            text += "Tipo de material foi modificado de #{RecursoEvento.find(m['recurso_evento_id'][0].to_i).nome}
                 para #{RecursoEvento.find(m['recurso_evento_id'][1].to_i).nome}"
          end
        end
      end
    end
    text
  end
  
	def class_by_status(status)
		#tatus de eventos
		return "icon icon-tick" if status.strip == "confirmado"
		return "icon icon-cancel" if status.strip == "cancelado"
		return "icon icon-error" if status.strip == "reservado"		
		
		#status de emprestimos
		return "icon icon-error" if status.strip == "por_atender"
		return "icon icon-group_add" if status.strip == "aguardando_autorizacao_superior"		
		return "icon icon-cancel" if status.strip == "cancelado"
		return "icon icon-user" if status.strip == "em_atendimento"
		return "icon icon-user" if status.strip == "atendido"
		return "icon icon-tick" if status.strip == "autorizado_por_superior"		
		return "icon icon-tick" if status.strip == "encerrado"
		return "icon icon-tick" if status.strip == "negado"
		return "icon icon-cancel" if status.strip == "nao_autorizado"
		return "icon icon-cancel" if status.strip == "expirado"
	end
	
	def auditoria_atualizacao(object)		
		"<div class='auditoria'><i>última atualização às #{object.updated_on.strftime('%H:%M:%S do dia %d/%m/%Y')}, por #{Pessoa.find(object.created_by).nome}</i></div>"
	end

end
