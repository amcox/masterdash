class SurveyResponseStringsController < ApplicationController
  before_action :set_survey_response_string, only: [:show, :edit, :update, :destroy]

  # GET /survey_response_strings
  # GET /survey_response_strings.json
  def index
    @survey_response_strings = SurveyResponseString.all
  end

  # GET /survey_response_strings/1
  # GET /survey_response_strings/1.json
  def show
  end

  # GET /survey_response_strings/new
  def new
    @survey_response_string = SurveyResponseString.new
  end

  # GET /survey_response_strings/1/edit
  def edit
  end

  # POST /survey_response_strings
  # POST /survey_response_strings.json
  def create
    @survey_response_string = SurveyResponseString.new(survey_response_string_params)

    respond_to do |format|
      if @survey_response_string.save
        format.html { redirect_to @survey_response_string, notice: 'Survey response string was successfully created.' }
        format.json { render action: 'show', status: :created, location: @survey_response_string }
      else
        format.html { render action: 'new' }
        format.json { render json: @survey_response_string.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /survey_response_strings/1
  # PATCH/PUT /survey_response_strings/1.json
  def update
    respond_to do |format|
      if @survey_response_string.update(survey_response_string_params)
        format.html { redirect_to @survey_response_string, notice: 'Survey response string was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @survey_response_string.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_response_strings/1
  # DELETE /survey_response_strings/1.json
  def destroy
    @survey_response_string.destroy
    respond_to do |format|
      format.html { redirect_to survey_response_strings_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_survey_response_string
      @survey_response_string = SurveyResponseString.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def survey_response_string_params
      params.require(:survey_response_string).permit(:text, :response_value, :response_type)
    end
end
