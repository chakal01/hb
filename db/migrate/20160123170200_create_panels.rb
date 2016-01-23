class CreatePanels < ActiveRecord::Migration
  def change
    create_table :panels do |t|
      t.string :title
      t.string :subtitle
      t.string :comment
      t.string :folder_name
      t.string :date
      t.integer :icon_id
      t.integer :ordre
      t.boolean :is_active
      t.timestamps, null: false
    end

  end
end
