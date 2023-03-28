class User < ApplicationRecord
  scope :internal_users, -> { where('email LIKE :soltech', soltech: '%soltechservice').order(:last_name)}

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :role, optional: true

  has_many :notifications, dependent: :destroy

  after_create :assign_role

  validates :first_name, length: { maximum: 64 }, presence: true
  validates :last_name, length: { maximum: 64 }, presence: true


  def has_role?(code)
    self.role == Role.find_by(code: code)
  end

  def self.non_admin
    user_ids = []
    User.all.each do |user|
      user_ids << user.id unless user.has_role?('super_admin')
    end
    User.where(id: user_ids).where.order(:first_name)
  end

  def to_s
    "#{last_name} #{first_name}"
  end

  def to_id
    "#{self.class.name}-#{id}".parameterize
  end

  def self.working_users
    user_ids = []
    User.all.each do |usr|
      user_ids << usr.id unless usr.has_role?('super_admin')
    end
    User.where(id: user_ids).order(:first_name)
  end

  private

  def assign_role
    if self.role.nil?
      self.update(role: Role.find_by_code('production'))
    end
  end
end
