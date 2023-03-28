class ImportRasterlink < ApplicationJob
  queue_as :nuova_algis
  sidekiq_options retry: 0, backtrace: 10

  def perform(args)
    CustomerMachine.where(import_job: 'rasterlink').each do |customer_machine|
      if customer_machine.present? && customer_machine.is_mounted?
        begin
          start = Time.now
          # List di tutti i file xml presenti nella cartella ed eventuali sotto cartelle
          Dir.glob("#{customer_machine.path}/**/*.xml").each do |xml_path|
            # Per ogni XML effettuo l'importazione
            IndustryDatum.transaction do
              doc = Nokogiri::XML(File.read(xml_path))
              job_name = doc.xpath("/java/object/void[@property='jobBasisProperty']/object/void[2]/object[1]/void[6]/string[2]").text.strip
              print_time = doc.xpath("/java/object/void[@property='ripProperty']/object/void[@property='timeCmdPrn']/long").text.strip.downcase
              next if print_time == '0'
              #import colori in un'unica stringa
              cyan = doc.xpath("/java/object/void/object/void[@property='inkUsed']/object[1]/void[1]/int[2]").text.strip.downcase
              magenta = doc.xpath("/java/object/void/object/void[@property='inkUsed']/object[1]/void[2]/int[2]").text.strip.downcase
              yellow = doc.xpath("/java/object/void/object/void[@property='inkUsed']/object[1]/void[3]/int[2]").text.strip.downcase
              black = doc.xpath("/java/object/void/object/void[@property='inkUsed']/object[1]/void[4]/int[2]").text.strip.downcase
              white1 = doc.xpath("/java/object/void/object/void[@property='inkUsed']/object[1]/void[5]/int[2]").text.strip.downcase
              white2 = doc.xpath("/java/object/void/object/void[@property='inkUsed']/object[1]/void[6]/int[2]").text.strip.downcase
              ink = "C:#{cyan};M:#{magenta};Y:#{yellow};B:#{black};W1:#{white1};W2:#{white2}"
              # Il tempo in java viene misurato in millisec dal 1970 mentre in Rails è misurato in secondi
              start_at = Time.at(doc.xpath("/java/object/void/object/void[@property='date']").text.strip.to_i/1000)
              details = {
                file_name:      job_name,
                start_at:       start_at,
                customer_machine_id: customer_machine.id,
                print_time:     print_time,
                copies:         doc.xpath("/java/object/void/object/void[@property='copyCount']").text,
                ink: ink
              }
              printer = IndustryDatum.find_by(details)
              if printer.nil?
                printer = IndustryDatum.create!(details)
                Log.create!(kind: 'success', action: "Import #{customer_machine}", description: "Caricato rasterlink per job #{job_name}")
              end
              File.rename(xml_path, "#{xml_path}.imported")
            end
          end
        rescue Exception => e
          log_details = {kind: 'error', action: "Import #{customer_machine}", description: e.message}
          if Log.where(log_details).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).size == 0
            Log.create!(log_details)
          end
          File.rename(xml_path, "#{xml_path}.error")
        end
      end
    end
  end
end
