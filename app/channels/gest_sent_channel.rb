class GestSentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "gest_sent"
    # stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
