class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string  :email,                null: false
      t.string  :first_name
      t.string  :last_name
      t.string  :language,             default: 'fr'
      t.string  :password_digest,      null: false
      t.boolean :admin,                null: false, default: false
      t.string  :token,                null: false
      t.string  :refresh_token,        null: false
      t.timestamps                     null: false
    end
    add_index :users, :email, :unique => true
  end
end
