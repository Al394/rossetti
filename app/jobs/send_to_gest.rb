class SendToGest < ApplicationJob
  queue_as :nuova_algis
  sidekiq_options retry: 0, backtrace: 10

  def perform(industry_datum_id)
    industry_datum = IndustryDatum.find(industry_datum_id)
    if industry_datum.present?
      begin
        client = TinyTds::Client.new(username: ENV['SQL_DB_USER'], password: ENV['SQL_DB_PSW'], host: ENV['SQL_DB_HOST'], port: ENV['SQL_DB_PORT'].to_i, database: ENV['SQL_DB'])
        GESTIONALE_LOGGER.info("okkkkkk")
        client.execute('SET ANSI_PADDING ON').do
        client.execute('SET ANSI_NULLS ON').do
        client.execute('SET CONCAT_NULL_YIELDS_NULL ON').do
        client.execute('SET ANSI_WARNINGS ON').do
        # tsql = "SET ANSI_NULLS ON"
        # result = client.execute(tsql)
        # tsql = "SET ANSI_WARNINGS ON"
        # result = client.execute(tsql)
        tsql = "INSERT INTO SOL_MOVIMENTI (ID_MACCHINA, NOME_FILE, INIZIO, DURATA, QTA_PRO, MATERIALE, INCHIOSTRI, EXTRA_DATA) VALUES (#{industry_datum.customer_machine.id}, '#{industry_datum.file_name}', '#{industry_datum.start_at.strftime("%Y%m%d %H:%M:%S")}', #{industry_datum.duration}, #{industry_datum.quantity}, '#{industry_datum.material}', '#{industry_datum.ink}', '#{industry_datum.extra_data}');"
        GESTIONALE_LOGGER.info("tsql == #{tsql.inspect}")
        client.execute(tsql)
        industry_datum.update!(sent_to_gest: DateTime.now)
      rescue Exception => e
        GESTIONALE_LOGGER.info("errore = #{e.message}")
        log_details = { kind: 'error', action: "Scrittura su tabella per dato: #{industry_datum.id} / #{industry_datum}", description: "#{e.message}" }
        if Log.where(log_details).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).size == 0
          Log.create!(log_details)
        end
      end
    end
  end
end
