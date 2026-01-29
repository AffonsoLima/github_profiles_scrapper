class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string :name, null: false
      t.string :github_url, null: false
      t.string :short_github_url
      t.string :github_username
      t.integer :followers
      t.integer :following
      t.integer :stars
      t.integer :contributions_last_year
      t.string :avatar_url
      t.string :location
      t.jsonb :organizations, default: []
      t.datetime :last_scraped_at

      t.timestamps
    end

    add_index :profiles, :github_username
    add_index :profiles, :organizations, using: :gin
  end
end
