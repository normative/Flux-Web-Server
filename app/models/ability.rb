class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # anon

    if user.persisted?
      can :read, User
      can :manage, User, { id: user.id }
      can :manage, Camera
      can :manage, Image
      can :manage, Tag
      can :manage, Category
    end
  end
end
