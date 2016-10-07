class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string      :email,                 null: false
      t.string      :password_digest,       null: false
      t.string      :token,                 null: false
      t.boolean     :admin,                 null: false, default: false
      t.string      :language,              null: false, default: "fr"
      t.timestamps                          null: false
    end
    add_index :users, :email, unique: true
  end
end
