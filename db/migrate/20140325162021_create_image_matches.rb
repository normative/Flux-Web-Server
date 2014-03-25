class CreateImageMatches < ActiveRecord::Migration
  def change
    create_table :image_matches do |t|
      t.integer :image_id, limit: 8
      t.integer :matching_id, limit: 8
      t.float :qw, :precision=>64, :scale=>12
      t.float :qx, :precision=>64, :scale=>12 
      t.float :qy, :precision=>64, :scale=>12
      t.float :qz, :precision=>64, :scale=>12
      t.float :t1, :precision=>64, :scale=>12
      t.float :t2, :precision=>64, :scale=>12
      t.float :t3, :precision=>64, :scale=>12
      t.timestamps
    end

    change_column :image_matches, :id, 'bigint'

  end
end
