class HomeController < ApplicationController
  
  def index
  	@upcoming_camps = Camp.active.upcoming.chronological.paginate(page: params[:ucpage]).per_page(10)
    if logged_in? 
      @instructor = current_user.instructor
      @assigned_camps = @current_user.instructor.camps.upcoming.chronological.paginate(page: params[:acpage]).per_page(10)
      if current_user.role? :admin
  		  @families = Family.alphabetical.paginate(page: params[:fpage]).per_page(10)
        @years = Camp.active.map{|c| c.start_date.year}.uniq
        @instructors = Instructor.active.alphabetical.paginate(page: params[:ipage]).per_page(10)
      end
  	end
  end

  def about
  end

  def contact
  end

  def privacy
  end
  
  def annual_report
    @year = params[:year]
    @camps_in_year = Camp.active.chronological.map{|c| c if c.start_date.to_date.year == @year.to_i}.compact.to_a
    @registrations_deposit_only = @camps_in_year.map{|c| c.registrations.deposit_only}.flatten.to_a
    @students = @registrations_deposit_only.map{ |r| r.student }.uniq.sort! { |a,b| a.name <=> b.name }.to_a

  end

end
