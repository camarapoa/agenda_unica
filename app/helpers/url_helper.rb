# Extensão para o helper +link_to+.
# O comportamento é o mesmo para o Rails atual (2.3.5). O que foi modificado/adicionado
# é a possibilidade de se passar a opção +icon+ para que um ícone de 16x16 px apareça do
# lado esquerdo do que quer que seja renderizado como texto (o resultado de um bloco também).
module UrlHelper
  def link_to(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second
      concat(link_to(capture(&block), options, html_options).html_safe!)
    else
      name         = args.first
      options      = args.second || {}
      html_options = args.third

      url = url_for(options)

      if html_options
        html_options = html_options.stringify_keys
        href = html_options['href']
        icon = html_options.delete('icon')
        convert_options_to_javascript!(html_options, url)
        tag_options = tag_options(html_options)
      else
        tag_options = nil
      end

      icon_tag = image_tag("icons/16x16/#{icon.to_s.tr('-', '_')}.png") + "&nbsp;" if icon      
      href_attr = "href=\"#{url}\"" unless href
      "<a #{href_attr}#{tag_options}>#{icon_tag}#{name || url}</a>".html_safe!
    end
  end
end