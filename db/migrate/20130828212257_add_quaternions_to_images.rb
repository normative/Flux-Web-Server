class AddQuaternionsToImages < ActiveRecord::Migration
  def change
    add_column :images, :raw_qw, :float
    add_column :images, :raw_qx, :float
    add_column :images, :raw_qy, :float
    add_column :images, :raw_qz, :float
    add_column :images, :best_qw, :float
    add_column :images, :best_qx, :float
    add_column :images, :best_qy, :float
    add_column :images, :best_qz, :float
  end
end
