
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

});