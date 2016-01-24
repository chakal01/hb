$(document).ready(function(){
  
  $("#email, #confirmEmail").keyup(function(){
    updateEmailError()
  })

  function updateEmailError(){
    if( $("#email").val() != $("#confirmEmail").val() ){
      $("#confirmEmail").parent().parent().addClass('has-error');
      $('#confirmEmail').tooltip('toggle')
    }else{
      $("#confirmEmail").parent().parent().removeClass('has-error');
      $('#confirmEmail').tooltip('toggle')
    }
  }

});