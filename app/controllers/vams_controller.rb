class VamsController < ApplicationController
  before_action :set_vam, only: [:show, :edit, :update, :destroy]

  # GET /vams
  # GET /vams.json
  def index
    @vams = Vam.all
  end

  # GET /vams/1
  # GET /vams/1.json
  def show
  end

  # GET /vams/new
  def new
    @vam = Vam.new
  end

  # GET /vams/1/edit
  def edit
  end

  # POST /vams
  # POST /vams.json
  def create
    @vam = Vam.new(vam_params)

    respond_to do |format|
      if @vam.save
        format.html { redirect_to @vam, notice: 'Vam was successfully created.' }
        format.json { render action: 'show', status: :created, location: @vam }
      else
        format.html { render action: 'new' }
        format.json { render json: @vam.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vams/1
  # PATCH/PUT /vams/1.json
  def update
    respond_to do |format|
      if @vam.update(vam_params)
        format.html { redirect_to @vam, notice: 'Vam was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @vam.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vams/1
  # DELETE /vams/1.json
  def destroy
    @vam.destroy
    respond_to do |format|
      format.html { redirect_to vams_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vam
      @vam = Vam.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vam_params
      params.require(:vam).permit(:subject, :teaching_id, :percentile)
    end
end
