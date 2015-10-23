class SchoolEnrollmentsController < ApplicationController
  before_action :set_school_enrollment, only: [:show, :edit, :update, :destroy]

  # GET /school_enrollments
  # GET /school_enrollments.json
  def index
    @school_enrollments = SchoolEnrollment.all
  end

  # GET /school_enrollments/1
  # GET /school_enrollments/1.json
  def show
  end

  # GET /school_enrollments/new
  def new
    @school_enrollment = SchoolEnrollment.new
  end

  # GET /school_enrollments/1/edit
  def edit
  end

  # POST /school_enrollments
  # POST /school_enrollments.json
  def create
    @school_enrollment = SchoolEnrollment.new(school_enrollment_params)

    respond_to do |format|
      if @school_enrollment.save
        format.html { redirect_to @school_enrollment, notice: 'School enrollment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @school_enrollment }
      else
        format.html { render action: 'new' }
        format.json { render json: @school_enrollment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /school_enrollments/1
  # PATCH/PUT /school_enrollments/1.json
  def update
    respond_to do |format|
      if @school_enrollment.update(school_enrollment_params)
        format.html { redirect_to @school_enrollment, notice: 'School enrollment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @school_enrollment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /school_enrollments/1
  # DELETE /school_enrollments/1.json
  def destroy
    @school_enrollment.destroy
    respond_to do |format|
      format.html { redirect_to school_enrollments_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school_enrollment
      @school_enrollment = SchoolEnrollment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def school_enrollment_params
      params.require(:school_enrollment).permit(:student_id, :school_id, :year_id, :grade, :entrydate, :exitdate)
    end
end
