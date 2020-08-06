// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).on('turbolinks:load', function() {
  const modal = $(".modal").modal({ duration: 200 });

  $(".js-admin-destroy").on("click", function(e) {
    modal.modal('show');
  })
});
