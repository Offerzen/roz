class TransactionsController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'transactions'

  def categorize
    id = transaction_params[:transaction_id]
    token = transaction_params[:token]
    @transaction = Transaction.find_by(id: id, token: token)
    
    if @transaction.nil?
      return head 401
    end

    if @transaction.confirmed?
      redirect_to transaction_success_path(@transaction)
    end

    @teams = Team.all.order(:name)
    @filter_team = params[:team_id].present? ? Team.find(params[:team_id]) : (@transaction.team || Team.find_by(default: true))
    @users = User.all.order(:name)
    @budget_categories = (@filter_team&.default ? BudgetCategory.all : BudgetCategory.where(special: false)).order(:name)
  end

  def confirm
    id = params[:transaction_id]
    token = confirmation_params[:token]
    @transaction = Transaction.find_by(id: id, token: token)

    if @transaction.nil?
      return head 401
    end

    unless transaction_valid?
      @teams = Team.all.order(:name)
      @filter_team = params[:team_id].present? ? Team.find(params[:team_id]) : @transaction.team
      @users = User.all.order(:name)
      @budget_categories = (@filter_team.default ? BudgetCategory.all : BudgetCategory.where(special: false)).order(:name)
      
      add_transaction_errors
      return render "categorize"
    end

    @transaction.update(
      user_id: confirmation_params[:user_id],
      confirmed_by_id: confirmation_params[:user_id],
      team_id: confirmation_params[:team_id],
      budget_category_id: confirmation_params[:budget_category_id],
      confirmation_state: "confirmed"
    )

    redirect_to transaction_success_path
  end

  def success
  end

  private

  def add_transaction_errors
    [:user_id, :team_id, :budget_category_id].each do |key|
      @transaction.errors.add(key, 'Required') if confirmation_params[key].empty?
    end
  end

  def transaction_valid?
    confirmation_params[:user_id].present? &&
      confirmation_params[:team_id].present? &&
      confirmation_params[:budget_category_id].present?
  end

  def transaction_params
    params.permit(
      :transaction_id,
      :token
    )
  end

  def confirmation_params
    params.permit(
      :token,
      :user_id,
      :budget_category_id,
      :team_id
    )
  end
end
