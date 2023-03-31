class ImportLiyuKonica < ApplicationJob
  queue_as :rossetti
  sidekiq_options retry: 0, backtrace: 10

  def perform
    CustomerMachine.where(import_job: 'liyu_konica').each do |customer_machine|
      if customer_machine.present? && customer_machine.is_mounted?
        file = "#{customer_machine.path}/#{Date.today.strftime("%Y%m")}.dat"
        if File.exist?(file)
          last_printer = customer_machine.industry_data.last
          details = {}
          File.open(file).each do |line|
            line = line.split(">")
            begin
              next if last_printer.present? && last_printer.start_at >= DateTime.parse(line.last.split.first).in_time_zone
              job_name = line[1]
              status = 'Completato'
              if line[6] != "100.0"
                status = 'Annullato'
              end
              details = {
                file_name: job_name,
                customer_machine_id: customer_machine.id,
                print_time: (convert_to_time(line.first) - convert_to_time(line.last.split.first)).to_i,
                start_at: convert_to_time(line.last.split.first),
                ends_at: convert_to_time(line.first),
                copies: 1,
                extra_data: "Stato: #{status}, N. passi: #{line[2]}, Risoluzione: #{line[4]}, MQ: #{line[5]}"
              }
              printer = IndustryDatum.find_by(details)
              if printer.nil?
                printer = IndustryDatum.create!(details)
                Log.create!(kind: 'success', action: "Import #{customer_machine} #{job_name}", description: "Caricati dati di stampa per riga ordine #{printer.resource}")
              end
            rescue Exception => e
              log_details = {kind: 'error', action: "Import #{customer_machine}", description: e.message}
              if Log.where(log_details).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).size == 0
                Log.create!(log_details)
              end
            end
          end
        end
      end
    end
  end

  def convert_to_time(date)
    begin
       date = Time.parse(date)
    rescue ArgumentError
       nil
    end
  end
end
