class Admin::CardsController < Admin::BaseController
  def index
    @cards = Card.all
  end

  def show
    @card = Card.find(params[:id])
  end

  def new
    @card = Card.new
    @teams = Team.all
    @users = User.all
  end

  def edit
    @card = Card.find(params[:id])
    @teams = Team.all
    @users = User.all
  end

  def create
    @card = Card.new(card_params)
    return redirect_to [:admin, @card] if @card.save

    flash[:error] = @card.errors.full_messages
    redirect_to [:new, :admin, :card]
  end

  def update
    @card = Card.find(params[:id])
    return redirect_to [:admin, @card] if @card.update(card_params)
    
    flash[:error] = @card.errors.full_messages
    redirect_to [:edit, :admin, @card]
  end

  def destroy
    @card = Card.find(params[:id])
    @card.destroy

    flash[:success] = "Card removed."
    redirect_to [:admin, :cards]
  end

  private

  def card_params
    params.require(:card).permit(
      :number,
      :team_id,
      :user_id
    )
  end
end
