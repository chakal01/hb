
$(document).ready(function(){

  /* Toggle panel is-active */
  $(".switch-is-active").click(function(){
    var thus = this
    $.ajax({
      url: "/admin/gallery/"+this.id+"/toggle",
    }).done(function() {
      $( thus ).toggleClass( "glyphicon-check");
      $( thus ).toggleClass( "glyphicon-unchecked" );
    });
  });


  /* Sortable table */
  /* Return a helper with preserved width of cells */
  var fixHelper = function(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  };

  $("#sortable tbody").sortable({
    helper: fixHelper,
    handle: ".sortable-handler",
    stop: function(){
      var list = [];
      $(".id").each(function(elem){
        list.push($(this).html());
      });
      $.ajax({
        method: 'post',
        url: "/admin/gallery/order",
        data: {"list": list}
      });
    }
  }).disableSelection();




});