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
            # trovo il job_name ciclando sul nome del csv e rimuovendo data e ora che il rasterlink mette al primo posto nel nome: es: 20211217_145057_59#J_test.pdf
            CSV.foreach(csv, headers: true, col_sep: ",", skip_blanks: true) do |row|
              inks = {}
              job_name = row['KEY_FILENAME']
              start_time = convert_to_time(row['KEY_PRINT_S_TIME'])
              end_time = convert_to_time(row['KEY_PRINT_E_TIME'])
              if row['KEY_INKUSE'].present?
                row['KEY_INKUSE'].split('cc ').each do |ink|
                  name, value = ink.split(':')
                  if inks[name].present?
                    inks[name] += value.to_f
                  else
                    inks[name] = value.to_f
                  end
                end
              end
              duration = end_time.max - start_time.min
              odl = job_name.split(Customization.import_separator).first
              details = {
                file_name: job_name,
                odl: odl,
                customer_machine_id: customer_machine.id,
                customer_machine_name: customer_machine.name,
                copies: 1,
                duration: duration,
                start_at: start_time,
                ends_at: end_time,
                ink: inks.map {|k, v| "#{k}:#{v}"}.join(';')
              }
              printer = IndustryDatum.find_by(details)
              if printer.nil?
                printer = IndustryDatum.create!(details)
                Log.create!(kind: 'success', action: "Import #{customer_machine}", description: "Caricato rasterlink per job #{job_name}".truncate(250))
              end
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
