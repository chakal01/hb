class CreateConstants < ActiveRecord::Migration
  def change
    create_table :constants do |t|
      t.string :key
      t.string :value
      t.string :label
      t.string :help
      t.string :input_type, default: 'text'
      t.timestamps null: false
    end
  end
end
