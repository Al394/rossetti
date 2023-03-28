class NotificationBroadcastJob < ApplicationJob
  queue_as :"nuova_algis"

  def perform(notification_id, counter)
    if notification_id.present?
      # Patch nel caso in cui abbia eliminato la notifica prima che parta il cron
      notification = Notification.find_by_id(notification_id)
      if notification.present?
        user = notification.user
        ActionCable.server.broadcast "notification_channel_#{user.id}", count: counter, counter: render_counter(counter), notification: render_notification(notification)
      end
    end
  end

  private

  def render_counter(counter)
    ApplicationController.renderer.render(partial: 'notifications/counter', locals: { counter: counter })
  end

  def render_notification(notification)
    ApplicationController.renderer.render(partial: 'notifications/notification', locals: { notification: notification })
  end
end
