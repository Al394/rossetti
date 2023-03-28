class Customization < ApplicationRecord
  scope :ordered, -> { order(parameter: :asc) }
  scope :internals, -> { where("parameter LIKE :license OR parameter LIKE :soltech", license: "license_%", soltech: "soltech_%") }
  scope :not_internals, -> { where.not("parameter LIKE :license OR parameter LIKE :soltech", license: "license_%", soltech: "soltech_%") }

  before_validation :check_customer_logo

  validates :parameter, presence: true, if: :validate_parameter?
  validates :value, presence: true, if: :validate_value?
  validates :customer_logo, presence: true, if: :validate_customer_logo?

  attr_accessor :customer_logo

  # Generic

  def self.import_separator
    Customization.where(parameter: 'import_separator').first.value
  end

  def self.tolerance
    Customization.where(parameter: 'back_tolerance').first.value.to_i
  end

  def self.customer_logo
    if File.exists?('public/customer_logo.png')
      "/customer_logo.png"
    else
      "print_logo_#{Customization.software_version}.png"
    end
  end

  # License

  def self.license_serial_number
    Customization.where(parameter: 'license_serial_number').first.value
  end

  def self.license_product_version
    Customization.where(parameter: 'license_product_version').first.value
  end

  def self.license_expiring_date
    Customization.where(parameter: 'license_expiring_date').first.value&.to_date
  end

  def self.license_error
    Customization.where(parameter: 'license_error').first.value
  end

  def self.license_token
    Customization.where(parameter: 'license_token').first.value
  end

  def self.license_backup_folder
    Customization.where(parameter: 'license_backup_folder').first.value
  end

  # Soltech

  def self.soltech_gest_url
    Customization.where(parameter: 'soltech_gest_url').first.value
  end

  def self.soltech_ftp_server
    Customization.where(parameter: 'soltech_ftp_server').first.value
  end

  def self.soltech_ftp_user
    Customization.where(parameter: 'soltech_ftp_user').first.value
  end

  def self.soltech_ftp_psw
    Customization.where(parameter: 'soltech_ftp_psw').first.value
  end

  def self.soltech_ftp_folder
    Customization.where(parameter: 'soltech_ftp_folder').first.value
  end

  def self.soltech_ftp_port
    Customization.where(parameter: 'soltech_ftp_port').first.value
  end

  def self.license_is_active?
    Customization.license_serial_number.present? && !Customization.license_expired?
  end

  def self.license_expiring?
    Customization.license_expiring_date.present? && (Customization.license_expiring_date >= Date.today)
  end

  def self.license_expired?
    Customization.license_expiring_date.present? && (Customization.license_expiring_date < Date.today)
  end

  def self.smtp_address
    Customization.where(parameter: 'smtp_address').first.value
  end

  def self.smtp_port
    Customization.where(parameter: 'smtp_port').first.value
  end

  def self.smtp_starttls
    Customization.where(parameter: 'smtp_starttls').first.value.to_boolean
  end

  def self.smtp_ssl_tls
    Customization.where(parameter: 'smtp_ssl_tls').first.value.to_boolean
  end

  def self.smtp_authentication_method
    Customization.where(parameter: 'smtp_authentication_method').first.value
  end

  def self.smtp_username
    Customization.where(parameter: 'smtp_username').first.value
  end

  def self.smtp_password
    Customization.where(parameter: 'smtp_password').first.value
  end

  def validate_parameter?
    true
  end

  def validate_value?
    !self.is_license_related? && !self.is_logo_related?
  end

  def validate_customer_logo?
    self.is_logo_related? && self.persisted?
  end

  def is_license_related?
    self.parameter.include?('license_')
  end

  def is_logo_related?
    self.parameter.include?('customer_logo')
  end

  #Customer FTP

    def self.customer_gest_url
    Customization.where(parameter: 'customer_gest_url').first.value
  end

  def self.customer_ftp_server
    Customization.where(parameter: 'customer_ftp_server').first.value
  end

  def self.customer_ftp_user
    Customization.where(parameter: 'customer_ftp_user').first.value
  end

  def self.customer_ftp_psw
    Customization.where(parameter: 'customer_ftp_psw').first.value
  end

  def self.customer_ftp_folder
    Customization.where(parameter: 'customer_ftp_folder').first.value
  end

  def self.latex_ftp_folder
    Customization.where(parameter: 'latex_ftp_folder').first.value
  end

  def self.stitch_ftp_folder
    Customization.where(parameter: 'stitch_ftp_folder').first.value
  end

  def self.customer_ftp_port
    Customization.where(parameter: 'customer_ftp_port').first.value
  end

  def to_s
    "#{parameter}"
  end

  private

  def check_customer_logo
    if self.customer_logo.present?
      directory = "public/customer_logo.png"
      File.open(directory, 'wb') do |f|
        f.write(self.customer_logo.read)
      end
      img = Magick::Image.read(directory).first
      cropped = img.resize_to_fit(10000, 50)
      cropped.write("public/customer_logo.png")
    end
  end
end
