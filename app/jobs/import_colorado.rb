class ImportColorado < ApplicationJob
  queue_as :nuova_algis
  sidekiq_options retry: 0, backtrace: 10

  def perform
    require 'net/http'
    require 'uri'
    require 'faraday'
    require 'mimemagic'
    require 'digest'

    CustomerMachine.where(import_job: 'colorado').each do |customer_machine|
      if customer_machine.present? && customer_machine.is_mounted?
        url = "http://#{customer_machine.ip_address}"
        conn = Faraday.new(url: url) do |faraday|
          faraday.adapter Faraday.default_adapter
        end
        res = conn.get("/accounting/#{customer_machine.serial_number}#{Date.today.strftime("%Y%m%d")}.acl") do |req|
          req.headers['charset'] = 'UTF-8'
        end
        PRINTER_LOGGER.debug "res = #{res.inspect}"
        now = Time.now.to_i
        dest_path = File.join(Rails.root, 'tmp/csv')
        FileUtils.mkdir_p dest_path
        csv = "#{dest_path}/#{now}.csv"
        f = File.open(csv, 'wb') { |fp| fp.write(res.body) }
        sleep 5
        begin
          if File.exist?(csv)
            last_printer = customer_machine.industry_data.order(job_id: :desc).first
            CSV.foreach(csv, headers: true, col_sep: ";", skip_blanks: true, encoding: 'windows-1252:utf-8', converters: :numeric) do |row|
              begin
                start_at = convert_to_time("#{row['startdate']} #{row['starttime']}")
                if last_printer.present? && row['jobid'] <= last_printer.job_id.to_i
                  if start_at <= last_printer.start_at
                    next
                  end
                end
                headers = row.headers
                ink = ""
                headers.each do |header|
                  if header.include?('inkcolor')
                    ink += "#{header.gsub('inkcolor', '')}: #{row[header].to_f / 1000.0};"
                  end
                end
                job_name = row[4]
                print_time = CustomerMachine.hour_to_seconds(row[8]) + CustomerMachine.hour_to_seconds(row[9])
                details = {
                  job_id: row[2],
                  file_name: job_name,
                  customer_machine_id: customer_machine.id,
                  start_at: start_at,
                  print_time: print_time,
                  copies: row[18],
                  material: row[20],
                  ink: ink
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
          else
            raise "File CSV non trovato"
          end
        rescue Exception => e
          PRINTER_LOGGER.info "Errore importazione dati #{customer_machine}: #{e.message}"
          log_details = {kind: 'error', action: "Import #{customer_machine}", description: e.message}
          if Log.where(log_details).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).size == 0
            Log.create!(log_details)
          end
        end
      end
    end
  end

  def convert_to_time(date)
    begin
       Time.zone.parse(date)
    rescue ArgumentError
       nil
    end
  end
end
