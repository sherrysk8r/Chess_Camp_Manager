class FamiliesController < ApplicationController 
	include ActionView::Helpers::NumberHelper
	authorize_resource
	before_action :set_family, only: [:show, :edit, :update, :destroy, :report, :yearly_report]

	def index
		@active_families = Family.active.alphabetical.paginate(page: params[:page]).per_page(10)
		@inactive_families = Family.inactive.alphabetical.paginate(page: params[:page]).per_page(10)
	end

	def show
		@children = @family.students.to_a
	end

	def new
		@family = Family.new
		@family.students.build
	end

	def edit
		@family.phone = number_to_phone(@family.phone)
		@family.students.build if @family.students.nil?
		@family.students.each do |student|
			student.date_of_birth = humanize_date student.date_of_birth
		end

	end

	def create
		params[:family][:students_attributes].values.each do |student|
		  student[:date_of_birth] = Chronic.parse(student[:date_of_birth])
		end if params[:family] and params[:family][:students_attributes]

		puts params[:family][:students_attributes]

		@family = Family.new(family_params)
		if @family.save
			redirect_to @family, notice: "#{@family.family_name} family was added to the system."
		else
			#@family.students.build
			render action: 'new'
		end
	end

	def update
		params[:family][:students_attributes].values.each do |student|
		  student[:date_of_birth] = Chronic.parse(student[:date_of_birth])
		end if params[:family] and params[:family][:students_attributes]

		if @family.update(family_params)
			redirect_to @family, notice: "#{@family.family_name} family was revised in the system."
		else
			render action: 'edit'
		end
	end

	def destroy
		@family.destroy
		redirect_to families_url, notice: "#{@family.family_name} was removed from the system."
	end

	def report
	    @registrations = @family.students.map{|s| s.registrations}.flatten.to_a
	    @camps = @family.students.map{|s| s.camps}.flatten.to_a
	    @years = @camps.map{|c| c.start_date.year}.uniq
	end

	def yearly_report
		@year = params[:year]
		@registrations = @family.students.map{|s| s.registrations}.flatten.to_a
		@registrations_in_year = @registrations.map { |r| r if r.camp.start_date.to_date.year == @year.to_i}.to_a
	end

	private
	def set_family
		@family = Family.find(params[:id])
	end

	def family_params
		params.require(:family).permit(:family_name, :parent_first_name, :email, :phone, :active, students_attributes: [:id, :first_name, :last_name, :rating, :date_of_birth, :active, :_destroy])
	end
end
