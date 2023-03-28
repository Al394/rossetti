import consumer from "./consumer"

consumer.subscriptions.create("GestSentChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    // console.log("Connected to the room!");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log('data', data)
    if (data.error == 'error') {
      $("#spinner").hide();
    }
    var resource_type = data.resource_type;
    var resource_id = data.resource_id;
    var date = data.sent_time;
    var element_id = "#" + resource_type + "_" + resource_id;
    var element = $(element_id)
    element.empty()
    element.text(date);
    $("#spinner").hide();
  }
});
