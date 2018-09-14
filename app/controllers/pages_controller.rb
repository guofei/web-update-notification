class PagesController < ApplicationController
  include ActionController::MimeResponds

  before_action :set_page, only: [:show, :update, :destroy, :crawled]

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

  def download
    respond_to do |format|
      format.csv { send_data Page.to_csv }
    end
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
    @page = Page.find_by(url: new_page.url, push_channel: new_page.push_channel)
    if @page
      # TODO use update
      @page.sec = new_page.sec
      @page.enable_js = new_page.enable_js
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
    if @page.update(page_params)
      head :no_content
    else
      render json: @page.errors, status: :unprocessable_entity
    end
  end

  # POST /pages/1
  # POST /pages/1.json
  def crawled
    if params[:error]
      @page.push_error_to_device(params[:message])
    else
      if params[:changed] == true
        @page.update(crawled_params)
        @page.push_to_device
      end
      # enqueue
      @page.set_next_job if params[:continue] == true
    end

    head :no_content
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
    params.require(:page).permit(
      :url,
      :sec,
      :push_channel,
      :stop_fetch,
      :enable_js
    )
  end

  def crawled_params
    params.require(:page).permit(:title, :content, :digest)
  end
end
