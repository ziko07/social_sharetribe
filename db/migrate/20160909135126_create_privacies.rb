class CreatePrivacies < ActiveRecord::Migration
  def change
    create_table :privacies do |t|
      t.string :person_id
      t.boolean :auto_follower, default: true

      t.timestamps null: false
    end
  end
end
