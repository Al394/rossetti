class ImportVersaWorks < ApplicationJob
  queue_as :demo
  sidekiq_options retry: 0, backtrace: 10

  def perform
    CustomerMachine.where(import_job: 'versa_works').each do |customer_machine|
      if customer_machine.present? && customer_machine.is_mounted?
        db = SQLite3::Database.open "#{customer_machine.path}/JobHistory.db"
        query = "SELECT ORP.Job_History_Key, JS.Job_Name, GROUP_CONCAT( SUBSTR(II.English,1,1) || ':' || IC.Consumption ,';') AS InkUse, ORP.Print_Start, ORP.Print_End, JS.Copies, CASE JH.Type WHEN '19' THEN 'Annullata' WHEN '25' THEN 'Completata' END Stato FROM operation_rip_print AS ORP INNER JOIN job_history AS JH ON ORP.Job_History_Key = JH.key INNER JOIN job_setting AS JS ON JH.job_setting_key = JS.key INNER JOIN ink_consumption AS IC ON JH.job_setting_key = IC.job_setting_key INNER JOIN ink_info AS II ON IC.ink_info_key = II.key WHERE ORP.Print_End IS NOT NULL AND ORP.Print_Start > date('now','-1 days') GROUP BY ORP.Job_History_Key ORDER BY ORP.Job_History_Key DESC; "

        # rimuovere 'AND ORP.Print_Start > date('now','-1 days')' dalla query se si vuole importare tutto dall'inizio

        db.execute(query) do |row|
          begin
            IndustryDatum.transaction do
              job_name = row[1]
              start_at = row[3].to_time
              end_at = row[4].to_time
              print_time = end_at - start_at
              start_at = row[3].to_time
              details = {
                customer_machine_id: customer_machine.id,
                start_at: start_at,
                print_time: print_time,
                ends_at: start_at + print_time&.to_i&.seconds,
                ink: row[2],
                job_id: row[0],
                copies: row[5],
                material: nil,
                extra_data: "Status: #{row[6]}"
              }
              printer = IndustryDatum.find_by(details)
              if printer.nil?
                printer = IndustryDatum.create!(details)
                Log.create!(kind: 'success', action: "Import #{customer_machine}", description: "Caricati dati di stampa per riga ordine #{printer.resource}")
              end
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
