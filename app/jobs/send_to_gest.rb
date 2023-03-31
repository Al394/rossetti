class SendToGest < ApplicationJob
  queue_as :rossetti
  sidekiq_options retry: 0, backtrace: 10

  def perform(industry_datum_id)
    
  end
end
