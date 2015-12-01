class PagesController < ApplicationController
  before_action :set_page, only: [:show, :update, :destroy]

  # GET /pages
  # GET /pages.json
  def index
    if params[:user_id]
      @pages = User.order(created_at: :desc).find(params[:user_id]).pages.where(stop_fetch: false)
    else
      @pages = Page.order(created_at: :desc).page params[:page]
    end

    render json: @pages
  end

  def csv
    render csv: send_data(Page.to_csv)
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    render json: @page and return
  end

  # POST /pages
  # POST /pages.json
  def create
    new_page = Page.new(page_params)
    @page = Page.find_by(url: new_page.url, push_channel: new_page.push_channel)
    if @page
      @page.sec = new_page.sec
      @page.stop_fetch = new_page.stop_fetch
      @page.save
      render json: @page, status: :created, location: @page
    else
      @page = new_page
      if @page.save
        render json: @page, status: :created, location: @page
      else
        render json: @page.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    @page = Page.find(params[:id])

    if @page.update(page_params)
      head :no_content
    else
      render json: @page.errors, status: :unprocessable_entity
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page.destroy

    head :no_content
  end

  private

    def set_page
      @page = Page.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:url, :sec, :push_channel, :stop_fetch)
    end
end
