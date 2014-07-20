class CampsController < ApplicationController
  authorize_resource
  skip_authorize_resource only: [:index, :show]
  before_action :set_camp, only: [:show, :edit, :update, :destroy, :report]

  def index
    @upcoming_camps = Camp.upcoming.active.chronological.paginate(page: params[:page]).per_page(10)
    @past_camps = Camp.past.chronological.paginate(page: params[:page]).per_page(10)
    @inactive_camps = Camp.inactive.alphabetical.to_a
  end

  def show
    @instructors = @camp.instructors.alphabetical.to_a
    @curriculum = @camp.curriculum
    @location = @camp.location
    @registered_students = @camp.students.alphabetical
    @registrations = @camp.registrations
  end

  def new
    @camp = Camp.new
  end

  def edit
    @camp = Camp.find(params[:id])
    @camp.start_date = humanize_date @camp.start_date
    @camp.end_date = humanize_date @camp.end_date
  end

  def create
    temp_camp_params = camp_params
    temp_camp_params[:start_date] = Chronic.parse(camp_params[:start_date])
    temp_camp_params[:end_date] = Chronic.parse(camp_params[:end_date])
   
    @camp = Camp.new(temp_camp_params)

    if @camp.save
      redirect_to @camp, notice: "The camp #{@camp.name} (on #{@camp.start_date.strftime('%m/%d/%y')}) was added to the system."
    else
      render action: 'new'
    end
  end

  def update
    temp_camp_params = camp_params
    temp_camp_params[:start_date] = Chronic.parse(camp_params[:start_date])
    temp_camp_params[:end_date] = Chronic.parse(camp_params[:end_date])

    begin
      @camp.update(temp_camp_params)
      redirect_to @camp, notice: "The camp #{@camp.name} (on #{@camp.start_date.strftime('%m/%d/%y')}) was revised in the system."
      
    rescue Exception => e
        flash[:error] = "This camp, or its instructor assignments are invalid."
        redirect_to edit_camp_path(@camp)
    end

    # if @camp.update(temp_camp_params)
    #   redirect_to @camp, notice: "The camp #{@camp.name} (on #{@camp.start_date.strftime('%m/%d/%y')}) was revised in the system."
    # else
    #   render action: 'edit', alert: "Something went wrong."
    # end
  end

  def destroy
    @camp.destroy
    redirect_to camps_url, notice: "#{@camp.name} camp on #{@camp.start_date.strftime('%m/%d/%y')} was removed from the system."
  end

  def report
    @registrations = @camp.registrations
  end

  private
    def set_camp
      @camp = Camp.find(params[:id])
    end

    def camp_params
      params.require(:camp).permit(:curriculum_id, :location_id, :cost, :start_date, :end_date, :time_slot, :max_students, :active, :instructor_ids => [])
    end
end
