class CreateSocialLinks < ActiveRecord::Migration
  def change
    create_table :social_links do |t|
      t.string :person_id
      t.string :facebook
      t.string :twitter

      t.timestamps null: false
    end
  end
end
