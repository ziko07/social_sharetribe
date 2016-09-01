class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :person_id
      t.string :post_to_id
      t.text :description

      t.timestamps null: false
    end
  end
end
