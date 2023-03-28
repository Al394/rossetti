class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.has_role? 'super_admin'
      can :manage, :all
      can :see_sidekiq, User
    elsif user.has_role? 'admin'
      can :manage, :all
      can :update, Customization
      cannot [:read], Role
      cannot [:create, :destroy], Customization
      cannot :see_sidekiq, User
    elsif user.has_role? 'production'
      can :manage, :all
      cannot :see_sidekiq, User
      cannot :manage, User
      cannot :manage, Customization
      can :manage, user
    end
  end
end
