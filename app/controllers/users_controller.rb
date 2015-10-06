class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def new
  	@user = User.new
  end

  def show
  	@user = User.find_by(id: params[:id])
    @entries = @user.entries.paginate(page: params[:page])
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
  		flash[:success] = "Welcome to the Blog App"
      log_in @user
  		redirect_to @user
  	else
  		render 'new'
  	end
  end  

  private
  	def user_params
  		params.require(:user).permit(:name,:email,:password,:password_confirmation)
  	end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
end
