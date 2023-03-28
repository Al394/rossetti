class ActiveStorageCleanUp < ApplicationJob
  queue_as :nuova_algis
  sidekiq_options retry: 1, backtrace: 10

  def perform
    if Date.yesterday.weekday? || (Date.yesterday.saturday? && Customization.work_on_saturday)
      CustomerMachine.check_industry_data_presence(Date.yesterday)
    end
  end
end
