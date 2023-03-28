class ImportSwissQ < ApplicationJob
  queue_as :nuova_algis
  sidekiq_options retry: 0, backtrace: 10

  require 'mysql2'

  def perform
    CustomerMachine.where(import_job: "swiss_q").each do |customer_machine|
      if customer_machine.present? && customer_machine.is_mounted?
        last_printer = IndustryDatum.last
        client = Mysql2::Client.new(host: customer_machine.ip_address, username: customer_machine.username, password: customer_machine.psw, port: 3306, database: "statistic")
        query = "SELECT I.RunID, J.Name, GROUP_CONCAT(C.ColorCode,':', I.Amount SEPARATOR ';') AS InkUse, IF(J.Result=0,'Completata','Annulata') AS Result, R.Execution, R.PrintTimespan, R.PrintedLength, R.PrintedSurface FROM inkusage AS I INNER JOIN Canister AS C ON I.CanisterUsageID = C.CanisterID INNER JOIN Jobs AS J ON I.RunID = J.JobID INNER JOIN Runs AS R ON J.JobID = R.RunID WHERE R.Execution > UNIX_TIMESTAMP(SUBDATE(NOW(),1))"
        query += " AND I.RunID > #{last_printer.job_id}" if last_printer.present?
        query += " GROUP BY I.RunID ORDER BY I.RunID;"
        results = client.query(query)
        results.each do |row|
          begin
            start_at = DateTime.strptime(row["Execution"].to_s, "%s")
            job_name = row["Name"]
            details = {
              customer_machine_id: customer_machine.id,
              job_id: row["RunID"],
              file_name: job_name,
              ink: row["InkUse"],
              start_at: start_at,
              print_time: row["PrintTimespan"],
              extra_data: "Stato: #{row['Result']}; Superficie di stampa (m²): #{row['PrintedSurface']}; Metri lineari: #{row['PrintedLength']}"
            }
            PRINTER_LOGGER.info "details = #{details}"
            printer = IndustryDatum.find_by(details)
            if printer.nil?
              printer = IndustryDatum.create!(details)
              Log.create!(kind: 'success', action: "Import #{customer_machine}", description: "Caricati dati di stampa per #{job_name}")
            end
          rescue Exception => e
            PRINTER_LOGGER.info("errore = #{e.message}")
            log_details = { kind: 'error', action: "Import #{customer_machine}", description: "#{e.message}" }
            if Log.where(log_details).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).size == 0
              Log.create!(log_details)
            end
          end
        end
      end
    end
  end
end
