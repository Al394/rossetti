class ImportLiyuRicoh < ApplicationJob
  queue_as :rossetti
  sidekiq_options retry: 0, backtrace: 10

  def perform
    CustomerMachine.where(import_job: 'liyu_ricoh').each do |customer_machine|
      if customer_machine.present? && customer_machine.is_mounted?
        files = Dir.glob("#{customer_machine.path}/#{Date.today.strftime("%Y")}/#{Date.today.strftime("%Y%m")}/#{Date.today.strftime("%Y%m%d")}/*.xml")
        begin
          raise "Nessun file trovato" if files.size == 0
          files.sort.each do |file|
            if customer_machine.industry_data.size > 0
              last_printer = customer_machine.industry_data.last
              next if last_printer.present? && last_printer.start_at.strftime("%Y%m%d%H%M%S").to_i >= File.basename(file).split(".xml").first.to_i
            end
            doc = Nokogiri::XML(File.read(file))
            doc.xpath("//PrintRecordList/PrintRecord").each do |row|
              next if last_printer.present? && last_printer.start_at >= DateTime.parse(row.xpath("UIJob/dateTime").text.strip).in_time_zone
              job_name = row.xpath("UIJob/string[1]").text.strip
              inks = ""
              row.xpath("ArrayOfInnerInkCount/InnerInkCount").each do |ink|
                ink = ink.text.strip.split("\n")
                inks += "#{ink.first}: #{ink.last.split(" ").first.to_f.round(7)}; "
              end
              print_time = row.xpath("long").text.strip
              # 7 sono gli zeri che mette Liyu dopo il numero reale di durata
              real_number = print_time.length - 7
              zeros = print_time[real_number..print_time.length]
              print_time = print_time.gsub("#{zeros}", '')
              details = {
                file_name: job_name,
                customer_machine_id: customer_machine.id,
                start_at: DateTime.parse(row.xpath("UIJob/dateTime").text.strip),
                print_time: print_time.to_i,
                ends_at: DateTime.parse(row.xpath("UIJob/dateTime").text.strip) + print_time&.to_i&.seconds,
                copies: 1,
                ink: inks
              }
              printer = IndustryDatum.find_by(details)
              if printer.nil?
                printer = IndustryDatum.create!(details)
                Log.create!(kind: 'success', action: "Import #{customer_machine}", description: "Caricati dati di taglio per #{job_name}")
              end
            rescue Exception => e
              log_details = {kind: 'error', action: "Import #{customer_machine}", description: e.message}
              if Log.where(log_details).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).size == 0
                Log.create!(log_details)
              end
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

  def convert_to_time(date)
    begin
       Time.parse(date)
    rescue ArgumentError
       nil
    end
  end
end
