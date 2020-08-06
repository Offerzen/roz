module TransactionsHelper
  def transaction_select_options(records)
    records.map { |record| {  value: record.id, label: record.name } }
  end
end
