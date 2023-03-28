import consumer from "./consumer"

consumer.subscriptions.create("SendProgramChannel", {
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
      $("#send_program_success").toggleClass("d-none").html("Invio ad hotfolder dei files completato per il programma " + data.program_name + ".");
    } else if (data.kind == 'danger') {
      $("#send_program_error").toggleClass("d-none").html("Errore durante l'invio ad hotfolder dei files per il programma " + data.program_name + ".");
    }
    if ($("#reload_program").length > 0) {
      $("#reload_program").html(data.program_html);
    }
  }
});
