class SendToFilemaker < ApplicationJob
  require 'uri'
  require 'net/http'
  queue_as :roberta_bolsi
  sidekiq_options retry: 0, backtrace: 10

  def perform(id)
    resource = IndustryDatum.find_by_id(id)
    token = resource.customer_machine.token
    auth = Base64.encode64("#{ENV['FILEMAKER_USER_NAME']}:#{ENV['FILEMAKER_PASSWORD']}").strip
    if resource.present?
      if token.nil? || (resource.customer_machine.updated_at < Time.now - 12.minutes)
        uri = URI("https://#{ENV['FILEMAKER_HOST']}/fmi/data/#{ENV['FILEMAKER_VERSION']}/databases/#{ENV['FILEMAKER_DB_NAME']}/sessions")
        request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json', 'Authorization' => 'Basic ' + auth })
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        begin
          response = http.request(request)
        rescue Exception => e
          MACHINE_LOGGER.info "Errore chiamata: #{e}"
          raise "ERRORE CONNESSIONE SERVER: #{e.message}"
        end
        res = JSON.parse(response.body)
        if response.code == '200'
          resource.customer_machine.update!(token: response['X-FM-Data-Access-Token'])
          MACHINE_LOGGER.info "Token ricevuto: #{response['X-FM-Data-Access-Token']}"
          resource.reload
          token = resource.customer_machine.token
        else
          MACHINE_LOGGER.info "Errore richiesta: codice #{JSON.pretty_generate(res)}"
          raise "ERRORE CONNESSIONE SERVER: #{response.code}"
        end
      end
      if token.present?
        uri = URI("https://#{ENV['FILEMAKER_HOST']}/fmi/data/#{ENV['FILEMAKER_VERSION']}/databases/#{ENV['FILEMAKER_DB_NAME']}/layouts/#{ENV['FILEMAKER_FORMAT_NAME']}/records")
        request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + token})
        print_data = Hash.new
        str_arr = resource.as_json(:except => [:id, :updated_at, :created_at, :customer_machine_id, :sent_to_gest_date, :resource_type, :resource_id, :folder, :sent_to_gest]).map do |k, v|
          [k, v].join(': ')
        end
        print_data['stringa'] = str_arr.join('; ')
        # print_data['start_at'] = print_data['start_at'].to_datetime.strftime('%d-%m-%Y %H:%M')
        print_data['macchina'] = resource.customer_machine.to_s
        data = { fieldData: print_data, "script":"Solinf_gestione"}
        # data = { fieldData: print_data }

        # data = { fieldData: print_data, "script.prerequest":"test_pre", "script.prerequest.param":"0", "script":"test", "script.param":"1", "script.presort":"test_post", "script.presort.param":"2"}
        # => Da conncordare gli script
        request.body = data.to_json
        MACHINE_LOGGER.info "REQUEST BODY: #{request.body}"
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        begin
          response = http.request(request)
        rescue Exception => e
          resource.customer_machine.update!(token: nil)
          MACHINE_LOGGER.info "Errore richiesta: #{e.message}"
          raise "ERRORE CONNESSIONE SERVER: #{e.message}"
        end
        if response.code == '200'
          resource.update_column(:sent_to_gest_date, DateTime.now)
          MACHINE_LOGGER.info "ESPORTAZIONE EFFETTUATA CORRETTAMENTE #{printer.customer_machine}: #{response.read_body}"
          response.header.each do |header|
            MACHINE_LOGGER.info "#{header} -> " + response["#{header}"].to_s
          end
          log_details = {kind: 'success', action: "Export #{printer.customer_machine}", description: response.body.to_s}

          Log.create!(log_details)

        else
          printer.customer_machine.update!(token: nil)
          MACHINE_LOGGER.info "Errore esportazione dati #{printer.customer_machine}: #{response.body.to_s}"
          log_details = {kind: 'error', action: "Export #{printer.customer_machine}", description: response.body.to_s}
          if Log.where(log_details).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).size == 0
            Log.create!(log_details)
          end
        end
      end
    end
  end
end
