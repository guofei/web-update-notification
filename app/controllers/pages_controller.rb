class PagesController < ApplicationController
  before_action :set_page, only: [:show, :update, :destroy]

  # GET /pages
  # GET /pages.json
  def index
    @pages = Page.all

    render json: @pages
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    render json: @page
  end

  # POST /pages
  # POST /pages.json
  def create
    new_page = Page.new(page_params)
    exist_page = Page.find_by(url: new_page.url, push_channel: new_page.push_channel)
    if exist_page
      exist_page.sec = new_page.sec
      exist_page.stop_fetch = new_page.stop_fetch
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
