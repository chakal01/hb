class AddPanelTypeToPanel < ActiveRecord::Migration
  def change
    change_table :panels do |t|
      t.string :panel_type
    end

  end
end
