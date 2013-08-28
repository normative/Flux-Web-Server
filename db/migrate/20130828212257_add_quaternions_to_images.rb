class AddQuaternionsToImages < ActiveRecord::Migration
  def change
    add_column :images, :raw_q1, :float
    add_column :images, :raw_q2, :float
    add_column :images, :raw_q3, :float
    add_column :images, :raw_q4, :float
    add_column :images, :best_q1, :float
    add_column :images, :best_q2, :float
    add_column :images, :best_q3, :float
    add_column :images, :best_q4, :float
  end
end
