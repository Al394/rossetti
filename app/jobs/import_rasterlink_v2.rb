class ImportRasterlinkV2 < ApplicationJob
  queue_as :rossetti
  sidekiq_options retry: 0, backtrace: 10

  def perform
    CustomerMachine.where(import_job: 'rasterlink_v2').each do |customer_machine|
      if customer_machine.present? && customer_machine.is_mounted?
        start = Time.now
        csv = ""
        begin
          Dir["#{customer_machine.path}/*.csv"].each do |csv|
            next if csv.include?('_NG_') || csv.include?('_cut.') || File.size(csv) == 0
            start_time = []
            end_time = []
            inks = {}
            # trovo il job_name ciclando sul nome del csv e rimuovendo data e ora che il rasterlink mette al primo posto nel nome: es: 20211217_145057_59#J_test.pdf
            job_name = File.basename(csv).split('_').drop(2).join('_')
            CSV.foreach(csv, headers: true, col_sep: ",", skip_blanks: true) do |row|
              start_time << row[5]
              end_time << row[6]
              if row[2].present?
                row[2].split('cc ').each do |ink|
                  name, value = ink.split(':')
                  if inks[name].present?
                    inks[name] += value.to_f
                  else
                    inks[name] = value.to_f
                  end
                end
              end
            end
            print_time = convert_to_time(end_time.max) - convert_to_time(start_time.min)
            odl = job_name.split(Customization.import_separator).first
            details = {
              file_name: job_name,
              odl: odl,
              customer_machine_id: customer_machine.id,
              customer_machine_name: customer_machine.name,
              copies: 1,
              print_time: print_time,
              start_at: convert_to_time(start_time.min),
              ends_at: convert_to_time(start_time.min) + print_time&.seconds,
              ink: inks.map {|k, v| "#{k}:#{v}"}.join(';')
            }
            printer = IndustryDatum.find_by(details)
            if printer.nil?
              printer = IndustryDatum.create!(details)
              Log.create!(kind: 'success', action: "Import #{customer_machine}", description: "Caricato rasterlink per job #{job_name}".truncate(250))
            end
            File.rename(csv, "#{csv}.imported")
          end
        rescue Exception => e
          log_details = {kind: 'error', action: "Import #{customer_machine}", description: e.message.truncate(250)}
          if Log.where(log_details).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).size == 0
            Log.create!(log_details)
          end
          # File.rename(csv, "#{csv}.error")
        end
      end
    end
  end

  def convert_to_time(date)
    begin
      Time.parse(date)
    rescue ArgumentError
      nil
    end
  end
end
