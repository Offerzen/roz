class ChangeDefaultOnConfirmationState < ActiveRecord::Migration[5.2]
  def change
    change_column :transactions, :confirmation_state, :string, default: 'unconfirmed'
  end
end
