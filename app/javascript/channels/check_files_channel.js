import consumer from "./consumer"

consumer.subscriptions.create("CheckFilesChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    $("#flash").toggleClass("d-none")
    if (data.kind == 'success') {
      if (!($("#check_files_error").hasClass("d-none"))) {
        $("#check_files_error").toggleClass("d-none")
      }
      $("#check_files_success").toggleClass("d-none").html("Controllo dei files completato per il programma " + data.program_name + ".");
    } else if (data.kind == 'danger') {
      if (!($("#check_files_success").hasClass("d-none"))) {
        $("#check_files_success").toggleClass("d-none")
      }
      $("#check_files_error").toggleClass("d-none").html("Errore durante il controllo dei files per il programma " + data.program_name + ".");
    }
    if ($("#reload_program").length > 0) {
      $("#reload_program").html(data.program_html);
    }
  }
});
