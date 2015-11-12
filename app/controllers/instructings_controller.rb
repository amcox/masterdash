class InstructingsController < ApplicationController
  before_action :set_instructing, only: [:show, :edit, :update, :destroy]

  # GET /instructings
  # GET /instructings.json
  def index
    @instructings = Instructing.all
  end

  # GET /instructings/1
  # GET /instructings/1.json
  def show
  end

  # GET /instructings/new
  def new
    @instructing = Instructing.new
  end

  # GET /instructings/1/edit
  def edit
  end

  # POST /instructings
  # POST /instructings.json
  def create
    @instructing = Instructing.new(instructing_params)

    respond_to do |format|
      if @instructing.save
        format.html { redirect_to @instructing, notice: 'Instructing was successfully created.' }
        format.json { render action: 'show', status: :created, location: @instructing }
      else
        format.html { render action: 'new' }
        format.json { render json: @instructing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instructings/1
  # PATCH/PUT /instructings/1.json
  def update
    respond_to do |format|
      if @instructing.update(instructing_params)
        format.html { redirect_to @instructing, notice: 'Instructing was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @instructing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instructings/1
  # DELETE /instructings/1.json
  def destroy
    @instructing.destroy
    respond_to do |format|
      format.html { redirect_to instructings_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_instructing
      @instructing = Instructing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def instructing_params
      params.require(:instructing).permit(:enrollment_id, :teaching_id, :start_date, :end_date, :lead)
    end
end
