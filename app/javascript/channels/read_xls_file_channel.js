import consumer from "./consumer"

consumer.subscriptions.create("ReadXlsFileChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    $("#flash").toggleClass("d-none")
    if (data.kind == 'checking') {
      if (!($("#read_xls_file_error").hasClass("d-none"))) {
        $("#read_xls_file_error").toggleClass("d-none")
      }
      if (!($("#read_xls_file_success").hasClass("d-none"))) {
        $("#read_xls_file_success").toggleClass("d-none")
      }
      $("#read_xls_file_checking").toggleClass("d-none").html("Lettura file per il programma " + data.program_name + " in corso.");
    } else if (data.kind == 'success') {
      if (!($("#read_xls_file_checking").hasClass("d-none"))) {
        $("#read_xls_file_checking").toggleClass("d-none")
      }
      if (!($("#read_xls_file_error").hasClass("d-none"))) {
        $("#read_xls_file_error").toggleClass("d-none")
      }
      $("#read_xls_file_success").toggleClass("d-none").html("Lettura file per il programma " + data.program_name + " completata con successo.");
    } else if (data.kind == 'danger') {
      if (!($("#read_xls_file_success").hasClass("d-none"))) {
        $("#read_xls_file_success").toggleClass("d-none")
      }
      if (!($("#read_xls_file_checking").hasClass("d-none"))) {
        $("#read_xls_file_checking").toggleClass("d-none")
      }
      $("#read_xls_file_error").toggleClass("d-none").html("Errore durante la lettura del file files per il programma " + data.program_name + ".");
    }
    if ($("#reload_program").length > 0) {
      $("#reload_program").html(data.program_html);
    }
  }
});
