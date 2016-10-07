class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.last 50

    render json: @users
  end

  # GET /users/1
  # GET /users/1.json
  def show
    render json: @user
  end

  # POST /users
  # POST /users.json
  def create
    new_user = User.new(user_params)
    @user = User.find_by(channel: new_user.channel)
    if @user
      if new_user.device_token && new_user.device_token != @user.device_token
        @user.device_token = new_user.device_token
        @user.save
      end
      @user.regist
      render json: @user, status: :created, location: @user
    else
      @user = new_user
      if @user.save
        @user.regist
        render json: @user, status: :created, location: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end
  end

  def touch
    channel = params[:user][:channel]
    @user = User.find_by(channel: channel)
    @user.touch if @user
    head :no_content
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    head :no_content
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name,
                                   :channel,
                                   :device_token,
                                   :device_type,
                                   :locale_identifier,
                                   :time_zone)
    end
end
