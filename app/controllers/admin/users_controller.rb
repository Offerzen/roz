class Admin::UsersController < Admin::BaseController
  def index
    @users = User.all.includes(:team, :cards).order(name: :asc)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @teams = Team.all
  end

  def edit
    @user = User.find(params[:id])
    @teams = Team.all.order(:name)
  end

  def create
    @user = User.new(user_params)
    return redirect_to [:admin, @user] if @user.save

    flash[:error] = @user.errors.full_messages
    redirect_to [:new, :admin, :user]
  end

  def update
    @user = User.find(params[:id])
    return redirect_to [:admin, @user] if @user.update(user_params)

    flash[:error] = @user.errors.full_messages
    redirect_to [:edit, :admin, @user]
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    flash[:success] = "User removed."
    redirect_to [:admin, :users]
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :slack_id,
      :email,
      :team_id,
      :role
    )
  end
end
