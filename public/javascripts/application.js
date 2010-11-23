jQuery.fn.submitSelected = function(el, url) {
  this.live('change', function() {
    jQuery(this).find('option:selected').each(function() {
      el.load(url, { id: jQuery(this).attr('value') } );
      return false;
    });
  });
};

jQuery(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});