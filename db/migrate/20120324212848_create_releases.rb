class CreateReleases < ActiveRecord::Migration[4.2]
  def change
    create_table :releases do |t|
      t.integer :environment_id
      t.string :name
      t.string :commit0
      t.string :commit1

      t.timestamps
    end
  end
end
