class Admin::TeamsController < Admin::BaseController
  def index
    @teams = Team.all.includes(:users).order(name: :asc)
  end

  def show
    @team = Team.find(params[:id])
  end

  def new
    @team = Team.new
    @cards = Card.all.where(team_id: nil, user_id: nil)
  end

  def edit
    @team = Team.find(params[:id])
    @cards = Card.all.select { |c| c.team == @team || (c.team == nil && c.user == nil) }.sort
  end

  def create
    @team = Team.new(team_params)
    return redirect_to [:admin, @team] if @team.save

    flash[:error] = @team.errors.full_messages
    redirect_to [:new, :admin, :team]
  end

  def update
    @team = Team.find(params[:id])
    return redirect_to [:admin, @team] if @team.update(team_params)

    flash[:error] = @team.errors.full_messages
    redirect_to [:edit, :admin, @team]
  end

  def destroy
    @team = Team.find(params[:id])
    @team.destroy

    flash[:success] = "Team removed."
    redirect_to [:admin, :teams]
  end

  private

  def team_params
    params.require(:team).permit(
      :name,
      :slack_id,
      :card_id,
      :group
    )
  end
end
