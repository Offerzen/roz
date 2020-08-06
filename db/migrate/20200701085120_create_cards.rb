class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
    	t.string :number
    	t.references :team, foreign_key: true
    	t.references :user, foreign_key: true
      t.datetime :deleted_at

    	t.timestamps
    end
    add_index :cards, :deleted_at

		add_reference :transactions, :card, foreign_key: true
  end
end
