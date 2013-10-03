class AddPosAccuracyToImages < ActiveRecord::Migration
  def up
    add_column :images, :horiz_accuracy, :float, default:0.0
    add_column :images, :vert_accuracy, :float, default:0.0
    add_column :images, :location_confidence, :float, default:0.0
  end

  def down
    remove_column :images, :horiz_accuracy
    remove_column :images, :vert_accuracy
    remove_column :images, :location_confidence
  end
end
