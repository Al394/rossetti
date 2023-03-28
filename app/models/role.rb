class Role < ApplicationRecord
  scope :ordered, -> { order(value: :asc) }
  scope :classical, -> { where.not(code: 'super_admin') }

  has_many :users

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :value, presence: true, numericality: { only_integer: true }, uniqueness: true

  def self.super_admin
    Role.find_by_code('super_admin')
  end

  def to_s
    name
  end
end
