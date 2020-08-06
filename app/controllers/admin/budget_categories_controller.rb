class Admin::BudgetCategoriesController < Admin::BaseController
  def index
    @budget_categories = BudgetCategory.all.order(:name)
  end
end
