module PaginationHelper
  
  def order_by(order_scope, options = {}, html_options = {})
    names = order_scope.to_s.split('.')
    options[:params_scope] ||= :search
    options[:as] ||= names.last.humanize
    ascend_scope  ||= "ascend_by_#{order_scope}"
    descend_scope ||= "descend_by_#{order_scope}"
    params_request = params[options[:params_scope]]
    
    if params_request
      ascending = params_request[:order].to_s == ascend_scope
      new_scope = ascending ? descend_scope : ascend_scope
      selected = [ascend_scope, descend_scope].include? params_request[:order].to_s
      if selected
        css_classes = html_options[:class].try(:split, ' ') || []
        css_classes.push ascending ? 'ascending' : 'descending'
        html_options[:class] = css_classes.join(' ')
      end
      new_params = params_request.merge(:order => new_scope)
      link_to options[:as], url_for("#{options[:params_scope]}" => new_params), html_options
    else
      link_to options[:as], url_for("#{options[:params_scope]}[order]" => new_scope), html_options
    end
  end
  
  def page_entries_info(collection, options = {})
    return "Sua pesquisa não retornou nenhum resultado." if collection.none?

    count = collection.size
    klass = collection.first.class
    human_name = klass.human_name(:count => count, :default => (count == 1 ? klass.to_s : klass.to_s.pluralize)).downcase
    
    content_tag :span, :class => 'pagination-entries-info' do
      if collection.total_pages < 2
        if count == 1
          "Exibindo <strong>1</strong> #{human_name}"
        else
          "Exibindo <strong>#{count}</strong> #{human_name}"
        end
      else
        %{Resultados <strong>%d&nbsp;-&nbsp;%d</strong> de <strong>%d</strong> #{human_name}} % [
          collection.offset + 1,
          collection.offset + collection.length,
          collection.total_entries
        ]
      end
    end
  end
  
  def paginate(list, klass = 'pagination')
    pagination = will_paginate(list)
    pagination if pagination
  end
  
  def show_entries_info(list, options = {})
    options.to_options!.reverse_merge! :singular => 'documento', :plural => 'documentos', :gender => 'male'
    return "#{page_entries_info(list, options)} <em>(#{pluralize(options[:time], 'segundo')})</em>" if options[:time]
    page_entries_info(list, options)
  end
  
end