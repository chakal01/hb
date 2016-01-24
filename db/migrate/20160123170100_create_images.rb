class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :name
      t.string :file_vignette
      t.string :file_normal
      t.integer :panel_id
      t.string :comment
      t.boolean :is_on_welcome_screen, default: false
      t.timestamps null: false
    end

  end
end
