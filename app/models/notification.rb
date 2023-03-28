class Notification < ApplicationRecord
  scope :unread, -> { where(read: false) }

  belongs_to :user
  belongs_to :resource, polymorphic: true, optional: true

  validates :user_id, inclusion: { in: Proc.new { User.ids } }, presence: true
  validates :kind, inclusion: { in: NOTIFICATION_KINDS }

  after_create_commit { NotificationBroadcastJob.perform_later(self.id, self.user.notifications.unread.size)}
  before_destroy { NotificationBroadcastJob.perform_later(self.id, self.user.notifications.unread.size - 1)}

  def to_s
    if self.kind == "missing_industry_data"
      "Dati 4.0 del #{I18n::l(Date.yesterday, format: :short)} mancanti per le seguenti macchine #{self.notes}."
    end
  end
end
