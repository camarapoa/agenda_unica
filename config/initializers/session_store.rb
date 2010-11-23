# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session =
  if Rails.env == 'development'
    {
      :session_key => '_camarapoa',
      :secret      => '6d3fb2a0cd7a049e27f77c8ca73fd590552776e47de47e3c7a44638bd4ab8add7140c11edd892a4d9d019d643a068c88d1a30c72b544b453ccdd8774a17ac589112081c779f51834a567314b95a0cdda01fe977b16440b721f6fde71ce0130b70c5bf90d1066bdef4e5ec08dca457522b0b399cf4567603b377efb28f701fc78'
    }
  elsif Rails.env == 'production'
    {
      :session_key => '_camarapoa',
      :secret      => '6d3fb2a0cd7a049e27f77c8ca73fd590552776e47de47e3c7a44638bd4ab8add7140c11edd892a4d9d019d643a068c88d1a30c72b544b453ccdd8774a17ac589112081c779f51834a567314b95a0cdda01fe977b16440b721f6fde71ce0130b70c5bf90d1066bdef4e5ec08dca457522b0b399cf4567603b377efb28f701fc78'
    }
  end

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
