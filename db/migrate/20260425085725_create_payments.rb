class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.string :merchant_id
      t.decimal :amount
      t.string :currency
      t.string :status
      t.string :failure_reason
      t.integer :retry_count
      t.integer :risk_score

      t.timestamps
    end
  end
end