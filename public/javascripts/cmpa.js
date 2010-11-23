var CMPA = (function() {
  var $j = null;
  
  return {
    initialize: function() {
      $j = jQuery.noConflict();
      
      $j.ajaxSetup({
        beforeSend: function(xhr) { xhr.setRequestHeader('Accept', 'text/javascript'); }
      });
      
      setDatepickerDefaults();
      setAjaxProgressIndicator();
      tooltips();
      flashMessages();
      menu();
  
      $j('form .focus').focus();
      $j('label.required').append('<span>**</span>');
      $j('.date').mask('99/99/9999').datepicker();
    },
    
    // Markitup tags
    getTextileSet: function() {
      return {
        previewParserPath: '/parse_textile', // path to your Textile parser
        onShiftEnter: { keepDefault:false, replaceWith:'\n\n' },
        markupSet: [
          { name:'Título 1', key:'1', openWith:'h1(!(([![Class]!]))!). ', placeHolder:'Título aqui...' },
          { name:'Título 2', key:'2', openWith:'h2(!(([![Class]!]))!). ', placeHolder:'Título aqui...' },
          { name:'Título 3', key:'3', openWith:'h3(!(([![Class]!]))!). ', placeHolder:'Título aqui...' },
          { name:'Título 4', key:'4', openWith:'h4(!(([![Class]!]))!). ', placeHolder:'Título aqui...' },
          { name:'Título 5', key:'5', openWith:'h5(!(([![Class]!]))!). ', placeHolder:'Título aqui...' },
          { name:'Título 6', key:'6', openWith:'h6(!(([![Class]!]))!). ', placeHolder:'Título aqui...' },
          { name:'Parágrafo', key:'P', openWith:'p(!(([![Class]!]))!). ' },
          { separator:'---------------' },
          { name:'Negrito', key:'B', closeWith:'*', openWith:'*' },
          { name:'Itálico', key:'I', closeWith:'_', openWith:'_' },
          { name:'Tachado', key:'S', closeWith:'-', openWith:'-' },
          { separator:'---------------' },
          { name:'Marcadores', openWith:'(!(* |!|*)!)' },
          { name:'Lista Numérica', openWith:'(!(# |!|#)!)' },
          { separator:'---------------' },
          { name:'Imagem', replaceWith:'![![Fonte:!:http://]!]([![Texto Alternativo]!])!' }, 
          { name:'Link', openWith:'"', closeWith:'([![Título]!])":[![Link:!:http://]!]', placeHolder:'Texto aqui...' },
          { separator:'---------------' },
          { name:'Aspas', openWith:'bq(!(([![Class]!])!)). ' },
          { name:'Código', openWith:'@', closeWith:'@' },
          { separator:'---------------' },
          { name:'Preview', call:'preview', className:'preview' }
        ]
      };
    }
    
  };
  
  function setDatepickerDefaults() {
    // Datepicker settings.
    $j.datepicker.regional['pt-BR'] = {
      closeText:         'Fechar',
      prevText:          '&laquo; Anterior',
      nextText:          'Próximo &raquo;',
      currentText:       'Hoje',
      monthNames:        ['Janeiro','Fevereiro','Março','Abril','Maio','Junho', 'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'],
      monthNamesShort:   ['Jan','Fev','Mar','Abr','Mai','Jun', 'Jul','Ago','Set','Out','Nov','Dez'],
      dayNames:          ['Domingo','Segunda-feira','Terça-feira','Quarta-feira','Quinta-feira','Sexta-feira','Sábado'],
      dayNamesShort:     ['Dom','Seg','Ter','Qua','Qui','Sex','Sab'],
      dayNamesMin:       ['Dom','Seg','Ter','Qua','Qui','Sex','Sab'],
      weekHeader:        'Sm',
      dateFormat:         'dd/mm/yy',
      firstDay:           0,
      isRTL:              false,
      showMonthAfterYear: false,
      yearSuffix:         ''
    };
    
    $j.datepicker.setDefaults(jQuery.datepicker.regional['pt-BR']);
    
    $j.datepicker.setDefaults({
      showOtherMonths: true,
      buttonImageOnly: true,
      buttonImage:     '/images/icons/16x16/calendar.png',
      showOn:          'button',
      dateFormat:      'dd/mm/yy',
      showAnim:        '',
      changeYear:      true,
      changeMonth:     true
    });
  }
  
  // Exibe e anima mensagens de flash.
  function flashMessages() {
    $flash = $j('#flash');
    if ($flash.length > 0) {
      $flash.hide().fadeIn('slow').delay(10000).fadeOut('slow');
      $j('#close-flash').click(function() {
        $flash.stop().fadeOut('slow');
        return false;
      });
    }
  }
    
  function tooltips() {
    if (typeof $j['tooltip'] != 'undefined') {
      $j('.tooltip').tooltip({
        showURL: false,
        track:   true,
        delay:   300,
        fade:    250
      });
    }
  }
    
  function setAjaxProgressIndicator() {
    $j('#loading-indicator')
      .ajaxSend(function() { $j(this).fadeIn('fast'); })
      .ajaxComplete(function() { $j(this).fadeOut('fast'); });
  }
  
  function menu() {
    var addArrowDown = function(menu) {
      $j(menu).find('li:has(ul) > a').each(function() {
        var link = $j(this);
        link.html( link.html() + '<small>&#9660;</small>' );
      });
    };
    
    var hideSubmenu = function(submenu, speed) {
      var speed = speed || 'fast';
      return $j(submenu).stop().fadeTo(speed, 0, function() {
        $j(this).hide();
      });
    };
    
    var addBubbleArrow = function(menu, header) {
      var bubbleArrow = $j('<img>', {
        src: '/images/icons/bubble_arrow.png',
        css: {
          zIndex: -1,
          position: 'absolute',
          bottom: 0,
          left: 30
        }
      });
      
      var selected = $j(menu).find('> li.selected');
      if (selected.length > 0) {
        var bubbleOffset = selected.position().left + selected.find('> a').width() / 2;
        bubbleArrow.css({ left: bubbleOffset }).appendTo($j(header));
      } else {
        bubbleArrow.appendTo($j(header));
      }        
    };
    
    // Marca elementos da DOM como selecionados usando a class 'selected'
    $j($j('body').attr('select_elements')).addClass('selected');
    
    var $menu = $j('#nav');
    addArrowDown($menu);
    addBubbleArrow($menu, '#header');
    
    // Fade submenu para opacidade zero por padrão.
    $menu.find('ul').css({ opacity: 0 });
    
    // Quando uma opção do menu/submenu for clicada o submenu, se estiver
    // visível, deve ser escondido.
    $menu.find('ul a, > li > a').click(function() {
      hideSubmenu($menu.find('ul'));
    });
    
    $menu.find('li').hoverIntent({
      sensitivity: 2,
      interval: 100,
      timeout: 500,
      over: function() {
        $j(this).find('ul').stop().fadeTo(200, 1).show();
      },
      out: function() {
        hideSubmenu($j(this).find('ul'));
      }
    });
  }
  
})();

jQuery(function() {
  CMPA.initialize();
});
