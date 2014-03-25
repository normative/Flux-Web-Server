class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # anon

    if user.persisted?
      can [:read, :profile, :avatar, :index, :lookupname], User
      can :manage, User, { id: user.id }
      can :manage, Camera
      can :manage, Image
      can :manage, Tag
      can :manage, Category
      can :manage, Alias, { user_id: user.id }
      can :manage, Connection, { user_id: user.id }
      can :getmatches, ImageMatch
    end
  end
end
