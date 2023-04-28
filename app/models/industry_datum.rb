class IndustryDatum < ApplicationRecord
  scope :ordered, -> { order(start_at: :desc) }
  scope :sent, -> { where.not(sent_to_gest: nil) }
  scope :unsent, -> { where(sent_to_gest: nil) }

  belongs_to :customer_machine, optional: true

  # after_create_commit :send_to_gest

  attr_accessor :is_plc

  validates :file_name, presence: true
  validates :duration, presence: true
  validates :start_at, presence: true

  alias_attribute :starts_at, :start_at
  alias_attribute :copies, :quantity
  alias_attribute :print_time, :duration
  alias_attribute :cut_time, :duration

  def validate_file_name?
    self.is_plc.blank?
  end

  def validate_duration?
    self.is_plc.blank?
  end

  def validate_start_at?
    true
  end

  def map_inks
    return '' if self.ink.blank?
    self.ink.split('; ').map {|ink| k,v = ink.split(':')}.to_h
  end

  def to_s
    "#{self.customer_machine.to_s} - #{self.start_at}"
  end

  private

  def send_to_gest
    # SendToFilemaker.perform_later(self.id)
  end
end
