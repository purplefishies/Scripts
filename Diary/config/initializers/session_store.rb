# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Diary_session',
  :secret      => '42b08e205bbcbe2410e55f77f98ee4098c211c839354bd265425d63ce17f56335530fa74292c49941d5a3ebf657e07313cb59e94e3054e2989648b864c2e6f6f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
