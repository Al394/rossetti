import consumer from "./consumer"

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    $('#notificationList').prepend(data.notification)
    var counter = $('#notification-counter')
    if (data.count > 0) {
      var icon = $('#notificationIcon')
      icon.addClass('faa-ring animated')
      var li = $('#notificationLi')
      li.addClass('active')
      var no_notification = $('#noNotification')
      no_notification.addClass('d-none');
    }
    counter.text(data.count);
  }
});
