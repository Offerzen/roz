class TransactionAutoCategorizerService
  def initialize(transaction)
    @transaction = transaction
  end

  def self.categorize!(transaction)
    new(transaction).categorize!
  end

  def categorize!
    match = find_similar_transaction
    update_transaction_to_match(match) if match.present?
    
    return { user: match.user, team: match.team } if match.present?
    nil
  end

  private

  def find_similar_transaction
    Transaction.where(
      card: transaction.card, 
      budget_category: BudgetCategory.find_by(name: 'Subscriptions'), 
      description: transaction.description)
    .order(date: :desc)
    .reject { |t| t == transaction }
    &.first
  end

  def update_transaction_to_match(match) 
    transaction.update(
      user: match.user,
      team: match.team,
      confirmation_state: 'auto-categorized'
    )
  end
    
  attr_reader :transaction

end
