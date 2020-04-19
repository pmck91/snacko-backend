class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authorize_as_admin, only: [:index]
  before_action :authenticate_user, only: [:update, :destroy]
  before_action :can_modify_user?, only: [:update, :destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  def find
    @user = User.find_by(email: params[:user][:email])
    if @user
      render json: @user
    else
      @errors = @user.errors.full_messages
      render json: @errors
    end
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    update_params = update_user_params
    if update_params[:password] != update_params[:repeat_password]
      render json: {error: "passwords do not match"}
    end
    update_params.remove(:repeat_password)
    if @user.update(update_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def can_modify_user?
    unauthorized_entity(current_user) unless current_user.can_modify_user?(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password)
  end

  def update_user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :repeat_password)
  end
end
