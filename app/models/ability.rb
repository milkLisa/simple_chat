class Ability
  include CanCan::Ability
  #alias_action :create, :read, :update, :destroy, :to => :crud

  def initialize(user)
    if user.blank? # not logged in
      cannot :manage, :all
    elsif user.has_any_role?(:system, :admin) #如果 role 為 system或admin
      can :manage, :all #可管理所有資源
    elsif user.has_any_role?(:mlo, :escrow) #如果 role 為 mlo或escrow
      can [:show, :update], User, id: user.id
      can :new, Conversation
      can :manage, Message
    else
      can [:show, :update], User, id: user.id
      can :new, Conversation
      can :manage, Message
    end
  end
  
end