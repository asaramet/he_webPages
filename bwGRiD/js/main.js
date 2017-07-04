$(document).ready(function() {
  //don't forget to start http server if run locally
  $.get("about.html", function(data) {
    $("#main_content").append("<div id='about'>" + data + "</div>");
  });

  $.get("links.html", function(data) {
    $("#about").after("<div id='links'>" + data +"</div>" );
  });
});
