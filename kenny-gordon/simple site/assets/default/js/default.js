/*
Add custom JS
*/
$(document).ready(function () {

  // Logfeed info modal
  $('#overlay').modal('show');
  setTimeout(function () {
    $('#overlay').modal('hide');
  }, 5000);

  // Logfeed refresh
  $("#result").load("output.php");
  setInterval(function () {
    $("#result").load("output.php");
  }, 60000);

  // Datatables
  $("#pga").DataTable({});


});