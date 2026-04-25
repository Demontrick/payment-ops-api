class CreateOperationLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :operation_logs do |t|
      t.references :payment, null: false, foreign_key: true
      t.string :action
      t.string :result
      t.string :worker_type

      t.timestamps
    end
  end
end