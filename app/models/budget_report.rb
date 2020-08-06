class BudgetReport

  def initialize(context:)
    @context = context
  end

  def transactions
    @transactions ||= begin
      transaction_scope = Transaction.includes(merchant: :budget_category)
      if @context.is_a?(User)
        transaction_scope = transaction_scope.where(user: @context)
      end
      transaction_scope
    end
  end

  def budget_category_monthly_allocations
    @budget_category_monthly_allocations ||= BudgetCategoryMonthlyAllocation.includes(:budget_category)
  end

  def transaction_total(budget_category)
    transactions.select do |t|
      t.merchant.budget_category == budget_category
    end.sum(&:amount)
  end

  def raw_result
    multipler = @context.is_a?(Team) ? User.count : 1

    hash = budget_category_monthly_allocations.map do |allocation|
      [
        allocation.budget_category.name,
        {
          budget_category_id: allocation.budget_category.id,
          transaction_total: transaction_total(allocation.budget_category),
          budget_total: (allocation.amount * multipler)
        }
      ]
    end.to_h

    hash["Uncategorized"] = {
      budget_category_id: 0,
      transaction_total: transaction_total(nil),
      budget_total: transaction_total(nil)
    }

    hash
  end

  def result
    raw_result.map do |name, data|
      [
        name,
        data.merge(
          budget_remaining: Money.new((data[:budget_total].to_d - data[:transaction_total].to_d) * 100, "ZAR"),
          budget_spent_percentage: (((data[:transaction_total].to_i / data[:budget_total].to_f) * 100).round rescue 0)
        )
      ]
    end.to_h
  end
end
