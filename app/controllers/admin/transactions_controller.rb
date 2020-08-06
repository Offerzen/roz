class Admin::TransactionsController < Admin::BaseController
  skip_before_action :authorize_admin, only: [:cash_report, :sage_report]

  def index
    @team = Team.includes(:users).first
    @teams = Team.all.order(name: :asc)
    @users = User.all.order(name: :asc)
    @scope = params[:scope] || 'all'

    @budget_categories = BudgetCategory.all.order(name: :asc)
    @uncategorized_transactions = Transaction.where(budget_category: nil)

    if @scope == 'uncategorized'
      @transactions = @uncategorized_transactions
    else
      @transactions = Transaction.all
    end

    @transactions = @transactions.order(date: :desc, id: :desc)
  end

  def update
    @transaction = Transaction.find(params[:id])

    if @transaction.update(
      transaction_params.merge(confirmation_state: 'confirmed', confirmed_by: current_user)
    )
      render json: { 
        transaction: @transaction, 
        group: @transaction.team&.group, 
        uncategorized: Transaction.where(budget_category: nil).count 
      }, status: 200
    else
      render json: { errors: @transaction.errors.full_messages }, status: 400
    end
  end

  def cash_report
    authorize current_user, :index?, policy_class: AdminPolicy

    @transactions = if params[:recent].present? && params[:recent] == 'true'
      Transaction.where(date: 30.days.ago..Float::INFINITY)
    else
      Transaction.all
    end

    @transactions = @transactions.order(date: :desc, id: :desc)

    csv = TransactionCsvExportService.generate_csv!(@transactions, :cash_report)

    send_data(csv, filename: 'cash_report.csv', type: 'text/csv', disposition: 'attachment')
  end

  def sage_report
    authorize current_user, :index?, policy_class: AdminPolicy

    @transactions = if params[:recent].present? && params[:recent] == 'true'
      Transaction.where(date: 30.days.ago..Float::INFINITY)
    else
      Transaction.all
    end

    @transactions = @transactions.order(date: :desc, id: :desc)

    csv = TransactionCsvExportService.generate_csv!(@transactions, :sage_report)

    send_data(csv, filename: 'sage_report.csv', type: 'text/csv', disposition: 'attachment')
  end

  private

  def transaction_params
    params.permit(:budget_category_id, :team_id, :user_id)
  end
end
