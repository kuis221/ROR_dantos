class GoompsController < ApplicationController
  before_action :set_goomp, only: [:show, :edit, :update, :destroy]

  # GET /goomps
  # GET /goomps.json
  def index
    @goomps = Goomp.all
  end

  # GET /goomps/1
  # GET /goomps/1.json
  def show
  end

  # GET /goomps/new
  def new
    @goomp = Goomp.new
  end

  # GET /goomps/1/edit
  def edit
  end

  # POST /goomps
  # POST /goomps.json
  def create
    @goomp = current_user.goomps.new(goomp_params)

    respond_to do |format|
      if @goomp.save
        format.html { redirect_to @goomp, notice: 'Goomp was successfully created.' }
        format.json { render :show, status: :created, location: @goomp }
      else
        format.html { render :new }
        format.json { render json: @goomp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /goomps/1
  # PATCH/PUT /goomps/1.json
  def update
    respond_to do |format|
      if @goomp.update(goomp_params)
        format.html { redirect_to @goomp, notice: 'Goomp was successfully updated.' }
        format.json { render :show, status: :ok, location: @goomp }
      else
        format.html { render :edit }
        format.json { render json: @goomp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /goomps/1
  # DELETE /goomps/1.json
  def destroy
    @goomp.destroy
    respond_to do |format|
      format.html { redirect_to goomps_url, notice: 'Goomp was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_goomp
      @goomp = Goomp.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def goomp_params
      params.require(:goomp).permit(:name, :cover, :slug, :price, :description, :memberships_count, :user_id)
    end
end
