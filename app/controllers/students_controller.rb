class StudentsController < ApplicationController
	authorize_resource
	before_action :set_student, only: [:show, :edit, :update, :destroy]

	def index
		@active_students = Student.active.alphabetical.paginate(page: params[:page]).per_page(10)
		@inactive_students = Student.inactive.alphabetical.paginate(page: params[:page]).per_page(10)
	end

	def show
		authorize! :show, @student
		@registrations = @student.registrations
		@qualified_camps = Curriculum.for_rating(@student.rating).map{|c| c.camps.upcoming.chronological}.flatten.to_a - @student.camps.upcoming.to_a
		@qualified_camps = @qualified_camps.compact
		@family = @student.family
	end

	def new
		@student = Student.new
	end

	def edit
		if !params[:status].nil? && params[:status] == "paid"
			registration = Registration.find(params[:id])
			registration.payment_status = "full"
			registration.save!
			flash[:notice] = "Registration for #{registration.student.proper_name} for #{registration.camp.name } has been fully paid."
			if params[:from] == "student"
				redirect_to student_path(@student)
			elsif params[:from] == "home"
				redirect_to home_path
			else
				redirect_to camp_path(registration.camp)
			end
		end

		@student.registrations.build if @student.registrations.nil?
		@student.date_of_birth = humanize_date @student.date_of_birth
	end

	def create
		temp_student_params = student_params
		temp_student_params[:date_of_birth] = Chronic.parse(student_params[:date_of_birth])

		@student = Student.new(temp_student_params)

		if @student.save
			redirect_to @student, notice: "#{@student.proper_name} was added to the system."
		else
			render action: 'new'
		end
	end

	def update
		temp_student_params = student_params
		temp_student_params[:date_of_birth] = Chronic.parse(student_params[:date_of_birth])

		if @student.update(temp_student_params)
			redirect_to @student, notice: "#{@student.proper_name} was revised in the system."
		else
			@student.registrations.build if @student.registrations.nil?
			render action: 'edit'
		end
	end

	def destroy
		@student.destroy
		redirect_to students_url, notice: "#{@student.proper_name} was removed from the system."
	end

	private
	def set_student
		@student = Student.find(params[:id])
	end

	def student_params
		params.require(:student).permit(:first_name, :last_name, :family_id, :date_of_birth, :rating, :active, registrations_attributes: [:id, :student_id, :camp_id, :payment_status, :points_earned, :_destroy])
	end
end
