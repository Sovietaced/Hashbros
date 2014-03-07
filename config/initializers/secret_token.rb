# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.

# Not really risky since we have a private repo
Hashbros::Application.config.secret_key_base = 'dc241cc34b8dddbbca9f8b62b7cef341f210cb85848f61afdecffcf29812d1bfd8eb183d85c013ce4565376deb02ce4a5e3ae2b182c4fd138e56336cd29ac64f'
