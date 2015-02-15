class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :username
      t.string :hostname
      t.string :location
      t.string :ssid
      t.float :rssi
      t.float :noise
      t.float :max_rate
      t.float :rate
      t.float :inet_speed
      t.float :inet_ping
      t.float :lan_speed
      t.float :lan_ping
      t.timestamp :timestamp
      t.timestamps null: false
    end
  end
end
