class CreateUserNotifications < ActiveRecord::Migration
  def change
    create_table :user_notifications do |t|
      t.string :sender
      t.string :person_id
      t.text :content
      t.boolean :is_read, default: false
      t.string :link
      t.string :event

      t.timestamps null: false
    end
  end
end
