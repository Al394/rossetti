class MountMachines < ApplicationJob
  queue_as :nuova_algis
  sidekiq_options retry: 0, backtrace: 10

  def perform
    # Provo a montare tutte le macchine
    CustomerMachine.mount_all

    # Verifico che i cron siano stati creati correttamente
    CustomerMachine.where.not(import_job: nil).each do |cm|
      job_class = "Import#{cm.machine.import_job.camelize}"
      job_name = "#{job_class}-#{cm.id}"
      job = Sidekiq::Cron::Job.find(job_name)
      if job.nil?
        Sidekiq::Cron::Job.create(name: job_name, cron: "*/#{cm.machine.cron_minutes} * * * *", class: job_class, queue: 'nuova_algis', description: "Import dati #{cm}", args: {customer_machine_id: cm.id})
      end
    end
  end
end
