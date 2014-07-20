class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role? :admin
      can :manage, :all
    elsif user.role? :instructor
      can :edit, User, instructor_id: user.instructor_id
      can :edit, Instructor, id: user.instructor_id
      can :update, Instructor, id: user.instructor_id
      can :show, Instructor

      can :read, :camps
      can :show, Student do |student|
        user.instructor.camps.map{|c| c.registrations}.flatten.to_a.map{|r| r.student_id}.include?(student.id)
      end
    else
      can :read, Camp
      can :show, Instructor
    end
  end
end