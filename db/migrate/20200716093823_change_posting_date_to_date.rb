class ChangePostingDateToDate < ActiveRecord::Migration[5.2]
  def change
    rename_column :transactions, :investec_posting_date, :date
  end
end
