// Links on tables woohoo!
$("tr[data-link]").click(function() {
  window.location = $(this).data("link")
})