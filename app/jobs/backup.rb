class Backup < ApplicationJob
  queue_as :rossetti
  sidekiq_options retry: 0, backtrace: 10

  def perform
    path = "#{ENV['BACKUP_FOLDER']}/#{Rails.env}.sql.gz"
    `mysqldump --opt #{config} | gzip -c | cat > #{path}`
    send_to_sftp!(path)
  end

  private

  def config(options = {})
    options[:database] ||= Rails.configuration.database_configuration[Rails.env]['database']
    options[:host] ||= Rails.configuration.database_configuration[Rails.env]['host']
    options[:password] ||= Rails.configuration.database_configuration[Rails.env]['password']
    options[:socket] ||= Rails.configuration.database_configuration[Rails.env]['socket']
    options[:username] ||= Rails.configuration.database_configuration[Rails.env]['username']
    "#{options[:host] ? "--host=#{options[:host]}" : "--socket=#{options[:socket]}"} -u #{options[:username]} -p#{options[:password]} #{options[:database]}"
  end

  def send_to_sftp!(file_path)
    if Rails.env != 'development' && Customization.license_backup_folder.present?
      server = Customization.soltech_ftp_server
      port = Customization.soltech_ftp_port || 22
      user = Customization.soltech_ftp_user
      password = Customization.soltech_ftp_psw
      folder = Customization.soltech_ftp_folder
      backup_path = "#{folder}/backup/#{Customization.license_backup_folder}"
      Net::SFTP.start(server, user, password: password, port: port.to_i) do |sftp|
        file_intro = "#{Date.today.strftime("%A")}_#{Time.now.hour}_"
        begin
          sftp.mkdir! backup_path
        rescue Net::SFTP::StatusException => e
          if e.code == 4
            # directory already exists. Carry on.
          else
            raise "Creazione cartella #{backup_path} non riuscita"
          end
        end
        sftp.upload(file_path, "#{backup_path}/#{file_intro}#{File.basename(file_path)}")
      end
    end
  end
end
