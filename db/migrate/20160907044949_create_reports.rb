class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :reportable_id
      t.string :reportable_type
      t.string :reported_by

      t.timestamps null: false
    end
  end
end
