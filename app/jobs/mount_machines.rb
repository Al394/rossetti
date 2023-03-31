class MountMachines < ApplicationJob
  queue_as :rossetti
  sidekiq_options retry: 0, backtrace: 10

  def perform
    # Provo a montare tutte le macchine
    CustomerMachine.mount_all
  end
end
