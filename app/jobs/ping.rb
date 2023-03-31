class Ping < ApplicationJob
  queue_as :rossetti
  sidekiq_options retry: 0, backtrace: 10

  def perform
    uri = URI.parse("#{Customization.soltech_gest_url}/ping")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json', token: Customization.license_token})
    # request.body = data.to_json
    response = http.request(request)
  end
end
