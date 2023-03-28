class CustomerMachine < ApplicationRecord
  scope :ordered, -> { order(:name) }

  has_many :industry_data, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  def self.mount_all
    begin
      CustomerMachine.all.each do |cm|
        if cm.is_mounted?
          cm.update!(is_mounted: true)
          next
        else
          cm.mount
          if cm.is_mounted?
            cm.update!(is_mounted: true)
            next
          end
        end
        cm.update!(is_mounted: false)
      end
      true
    rescue Exception => e
      false
    end
  end

  def self.hour_to_seconds(time)
    print_time = 0
    time.split(':').each_with_index do |time, index|
      if index == 0
        print_time += time.to_i * 3600
      elsif index == 1
        print_time += time.to_i * 60
      else
        print_time += time.to_i
      end
    end
    print_time
  end


  def self.ping(host)
    check = Net::Ping::External.new(host)
    check.ping?
  end

  def self.check_industry_data_presence(date)
    cm_without_data = nil
    raise 'missing date' if date.blank?
    cm_with_data_today = CustomerMachine.joins(:industry_data).where('industry_data.created_at BETWEEN ? AND ?', date.beginning_of_day, date.end_of_day).distinct.ids
    cm_without_data = CustomerMachine.where.not(id: cm_with_data_today)
    if cm_without_data.size > 0
      User.all.each do |user|
        Notification.create!(kind: "missing_industry_data", notes: cm_without_data.pluck(:name).join('; '), user_id: user.id)
        NotificationMailer.send('missing_data', user, cm_without_data.pluck(:name)).deliver_now
        Log.create!(kind: 'error', action: "Dati 4.0 mancanti.", description: "Dati 4.0 del #{I18n::l(Date.yesterday, format: :short)} mancanti per le seguenti macchine: #{cm_without_data.pluck(:name).join('; ')}.")
      end
    end
  end

  def is_mounted?
    ret = false
    if self.path.present?
      timeout = Time.now.to_i + 2
      begin
        loop do
          if Dir.glob("#{self.path}/*").size > 0
            ret = true
            break
          else
            raise "Error" if Time.now.to_i > timeout
          end
        end
      rescue Exception => e
        ret = false
      end
    elsif self.ip_address.present?
      ret = CustomerMachine.ping(self.ip_address)
    else
      ret = true
    end
    ret
  end

  def mount
    system("mount #{self.path}")
  end

  def to_s
    name
  end
end
