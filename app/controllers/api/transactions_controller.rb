class API::TransactionsController < API::BaseController

  def create
    card = Card.find_by(number: transaction_params[:card_number])
    user = User.find_by(card: card)
    team = Team.find_by(card: card) || Team.find_by(name: 'finops')

    if user.nil? && team.nil?
    	raise "Unable to associate transaction to user or team"
	    return head 500
		end

    if user
	    user.transactions.create!(create_transaction_params)
		else
	    team.transactions.create!(create_transaction_params) 
		end

    head :ok
  end

private
	def create_transaction_params
    amount = Money.new(transaction_params[:amount_cents], "ZAR")

		{
			amount: amount, 
			investec_id: transaction_params[:id],
			description: transaction_params[:description],
			card_number: transaction_params[:card_number]
		}
	end

  def transaction_params
    params.require(:transaction).permit(:amount_cents, :account_id, :type, :status, :description, :card_number, :date, :posting_date, :value_date, :action_date)
  end
end
