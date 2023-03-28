class ImportZund < ApplicationJob
  queue_as :nuova_algis
  sidekiq_options retry: 0, backtrace: 10

  def perform(args)
    CustomerMachine.where(import_job: 'zund').each do |customer_machine|
      if customer_machine.present? && customer_machine.is_mounted?
        Dir.glob("#{customer_machine.path}/*.xml").each do |xml_path|
          # Per ogni XML effettuo l'importazione
          begin
            doc = Nokogiri::XML(File.read(xml_path))
            job_name = doc.xpath("//JobStatus/@Name").text.strip
            details = {
              file_name: job_name,
              customer_machine_id: customer_machine.id,
              cut_time: (convert_to_time(doc.xpath("//JobStatus/@EndTime").text.strip) - convert_to_time(doc.xpath("//JobStatus/@StartTime").text.strip)).to_i,
              starts_at: convert_to_time(doc.xpath("//JobStatus/@StartTime").text.strip),
              ends_at: convert_to_time(doc.xpath("//JobStatus/@EndTime").text.strip),
              quantity: doc.xpath("//JobStatus/@DoneCopies").text.strip.to_i
            }
            cutter = IndustryDatum.find_by(details)
            if cutter.nil?
              cutter = IndustryDatum.create!(details)
              # File.rename(xml_path, "#{xml_path}.imported")
              dir = "#{customer_machine.path}/imported"
              FileUtils.mkdir_p(dir) unless File.directory?(dir)
              FileUtils.mv xml_path, "#{dir}/#{File.basename(xml_path)}"
              Log.create!(kind: 'success', action: "Import #{customer_machine}", description: "Caricati dati di taglio per #{job_name}")
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

  def convert_to_time(date)
    begin
       Time.parse(date)
    rescue ArgumentError
       nil
    end
  end
end
