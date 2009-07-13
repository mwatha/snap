# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_snap_session',
  :secret      => 'c65a50d4035d365066d73aaeaa47792f78414a8b0fc0dc304310dd506375ee78b33e3973fb405abf6e0de5a3364278020d22cdb11f81564abd18b3daf8123ae0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
