puts "Importing Roles..."
if Role.where(code: 'super_admin').size == 0
  Role.create!(code: 'super_admin', name: 'Super Amministratore', value: 10)
end

if Role.where(code: 'admin').size == 0
  Role.create!(code: 'admin', name: 'Amministratore', value: 20)
end

if Role.where(code: 'production').size == 0
  Role.create!(code: 'production', name: 'Produzione', value: 40)
end
puts "Roles imported. "

puts "Importing Users..."
# Users
json = ActiveSupport::JSON.decode(File.read('db/seeds/users.json'))
json.each do |environment, users|
  next if environment == 'development' && Rails.env != 'development'
  users.each do |user|
    next if User.find_by(email: user['email']).present?
    usr = User.create!(user)
  end
end

if Rails.env == 'development'
  User.all.each do |user|
    user.password = '123456'
    user.save!
  end
end
puts "Users imported. "

if Customization.where(parameter: 'soltech_ftp_server').size == 0
  Customization.create!(parameter: 'soltech_ftp_server', value: 'gest.soltech.cloud', notes: 'Server FTP per esportazione backup')
end

if Customization.where(parameter: 'soltech_ftp_user').size == 0
  Customization.create!(parameter: 'soltech_ftp_user', value: 'soltech', notes: 'Utente FTP per esportazione backup')
end

if Customization.where(parameter: 'soltech_ftp_psw').size == 0
  Customization.create!(parameter: 'soltech_ftp_psw', value: 'S0lt3chFtp', notes: 'Password FTP per esportazione backup')
end

if Customization.where(parameter: 'soltech_ftp_folder').size == 0
  Customization.create!(parameter: 'soltech_ftp_folder', value: '/soltech/ftp/files', notes: 'Cartella FTP per esportazione backup')
end

if Customization.where(parameter: 'soltech_ftp_port').size == 0
  Customization.create!(parameter: 'soltech_ftp_port', value: '1022', notes: 'Porta FTP per esportazione backup')
end

if Customization.where(parameter: 'license_backup_folder').size == 0
  Customization.create!(parameter: 'license_backup_folder', value: 'rossetti', notes: 'Cartella backup su ftp')
end

if Customization.where(parameter: 'smtp_address').size == 0
  Customization.create!(parameter: 'smtp_address', value: "smtps.aruba.it", notes: 'Indirizzo SMTP')
else
  Customization.find_by(parameter: 'smtp_address').update!(value: "smtps.aruba.it")
end

if Customization.where(parameter: 'smtp_port').size == 0
  Customization.create!(parameter: 'smtp_port', value: "465", notes: 'Porta SMTP')
else
  Customization.find_by(parameter: 'smtp_port').update!(value: "465")
end

if Customization.where(parameter: 'smtp_starttls').size == 0
  Customization.create!(parameter: 'smtp_starttls', value: "false", notes: 'Abilitare STARTTLS (true/false)')
else
  Customization.find_by(parameter: 'smtp_starttls').update!(value: "false")
end

if Customization.where(parameter: 'smtp_ssl_tls').size == 0
  Customization.create!(parameter: 'smtp_ssl_tls', value: "true", notes: 'Abilitare SSL/TLS (true/false)')
else
  Customization.find_by(parameter: 'smtp_ssl_tls').update!(value: "true")
end

if Customization.where(parameter: 'smtp_authentication_method').size == 0
  Customization.create!(parameter: 'smtp_authentication_method', value: "plain", notes: 'Metodo di autenticazione SMTP (plain/login/cram_md5)')
else
  Customization.find_by(parameter: 'smtp_authentication_method').update!(value: "plain")
end

if Customization.where(parameter: 'smtp_username').size == 0
  Customization.create!(parameter: 'smtp_username', value: "support@soltechservice.it", notes: 'Nome utente SMTP')
else
  Customization.find_by(parameter: 'smtp_username').update!(value: "support@soltechservice.it")
end

if Customization.where(parameter: 'smtp_password').size == 0
  Customization.create!(parameter: 'smtp_password', value: "SS#947up!@@", notes: 'Password SMTP')
else
  Customization.find_by(parameter: 'smtp_password').update!(value: "SS#947up!@@")
end

if Customization.where(parameter: 'soltech_gest_url').size == 0
  Customization.create!(parameter: 'soltech_gest_url', value: 'http://gest.soltech.cloud/api/v1', notes: 'API')
end

if Customization.where(parameter: 'license_token').size == 0
  Customization.create!(parameter: 'license_token', value: ENV['SS_GEST_TOKEN'], notes: 'Token licenza')
end

if Customization.where(parameter: 'import_separator').size == 0
  Customization.create!(parameter: 'import_separator', value: '#', notes: 'Inserire il separatore dei jobs')
end

sg2 = CustomerMachine.find_by(serial_number: 'SG2-300')
lef2 = CustomerMachine.find_by(serial_number: 'LEF2-300 DX')

sg2.update!(serial_number: 'KEE0390')
lef2.update!(serial_number: 'ZEB0133')

CustomerMachine.create!(name: 'LEF-20', serial_number: 'ZCI2899', path: '/srv/vhosts/soltechws/share/LOG_VERSA', import_job: 'versa_works')

CustomerMachine.mount_all