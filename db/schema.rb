# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140221114553) do

  create_table "blocks", force: true do |t|
    t.integer  "round_id",   null: false
    t.string   "category"
    t.float    "amount"
    t.string   "txid"
    t.string   "blockhash"
    t.datetime "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blocks", ["round_id"], name: "index_blocks_on_round_id"

  create_table "coin_histories", force: true do |t|
    t.integer  "volume"
    t.float    "diff"
    t.integer  "coin_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "time"
    t.integer  "blocks"
    t.float    "ask"
    t.float    "bid"
    t.float    "liquidity_premium"
    t.float    "depth"
    t.float    "profitability"
    t.float    "btc_per_day"
    t.integer  "network_hash_rate", limit: 8
    t.float    "exchange_rate"
  end

  add_index "coin_histories", ["coin_id"], name: "index_coin_histories_on_coin_id"
  add_index "coin_histories", ["created_at"], name: "index_coin_histories_on_created_at"

  create_table "coins", force: true do |t|
    t.string   "name"
    t.float    "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "symbol"
    t.float    "reward"
    t.string   "cryptsy_address"
    t.string   "hashbros_address"
    t.integer  "cryptsy_market_id"
    t.decimal  "transaction_fee",             default: 0.0005
    t.integer  "blocks"
    t.integer  "network_hash_rate", limit: 8
    t.float    "exchange_rate"
  end

  add_index "coins", ["name"], name: "index_coins_on_name"
  add_index "coins", ["symbol"], name: "index_coins_on_symbol"

  create_table "debts", force: true do |t|
    t.integer "user_id"
    t.float   "btc"
    t.boolean "paid"
  end

  add_index "debts", ["user_id"], name: "index_debts_on_user_id"

  create_table "deposits", force: true do |t|
    t.integer  "round_id"
    t.string   "exchange_address", null: false
    t.datetime "time_finished"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "reported_amount"
    t.float    "confirmed_amount"
    t.string   "txid"
    t.integer  "worker_credit_id"
    t.float    "fees"
  end

  add_index "deposits", ["round_id"], name: "index_deposits_on_round_id"
  add_index "deposits", ["status"], name: "index_deposits_on_status"
  add_index "deposits", ["time_finished"], name: "index_deposits_on_time_finished"
  add_index "deposits", ["txid"], name: "index_deposits_on_txid"
  add_index "deposits", ["worker_credit_id"], name: "index_deposits_on_worker_credit_id"

  create_table "exchanges", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "markets", force: true do |t|
    t.integer  "exchange_id"
    t.integer  "offer_coin_id"
    t.integer  "sell_coin_id"
    t.float    "exchange_rate",       default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "exchange_market_key"
  end

  add_index "markets", ["exchange_id"], name: "index_markets_on_exchange_id"
  add_index "markets", ["offer_coin_id"], name: "index_markets_on_offer_coin_id"
  add_index "markets", ["sell_coin_id"], name: "index_markets_on_sell_coin_id"

  create_table "monologue_posts", force: true do |t|
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "title"
    t.text     "content"
    t.string   "url"
    t.datetime "published_at"
  end

  add_index "monologue_posts", ["url"], name: "index_monologue_posts_on_url", unique: true

  create_table "monologue_taggings", force: true do |t|
    t.integer "post_id"
    t.integer "tag_id"
  end

  add_index "monologue_taggings", ["post_id"], name: "index_monologue_taggings_on_post_id"
  add_index "monologue_taggings", ["tag_id"], name: "index_monologue_taggings_on_tag_id"

  create_table "monologue_tags", force: true do |t|
    t.string "name"
  end

  add_index "monologue_tags", ["name"], name: "index_monologue_tags_on_name"

  create_table "monologue_users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.integer  "user_id",                    null: false
    t.integer  "category",                   null: false
    t.integer  "target_id",                  null: false
    t.boolean  "read",       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id"

  create_table "orders", force: true do |t|
    t.integer  "cryptsy_order_id", null: false
    t.integer  "round_id",         null: false
    t.float    "price",            null: false
    t.float    "quantity",         null: false
    t.string   "status"
    t.datetime "time_finished"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["cryptsy_order_id"], name: "index_orders_on_cryptsy_order_id"
  add_index "orders", ["round_id"], name: "index_orders_on_round_id"
  add_index "orders", ["status"], name: "index_orders_on_status"

  create_table "payouts", force: true do |t|
    t.integer  "worker_credit_id", null: false
    t.float    "fees"
    t.boolean  "is_redeemed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount"
    t.string   "status"
    t.integer  "redemption_id"
    t.integer  "coin_id"
  end

  add_index "payouts", ["amount"], name: "index_payouts_on_amount"
  add_index "payouts", ["coin_id"], name: "index_payouts_on_coin_id"
  add_index "payouts", ["redemption_id"], name: "index_payouts_on_redemption_id"
  add_index "payouts", ["worker_credit_id"], name: "index_payouts_on_worker_credit_id", unique: true

  create_table "pool_histories", force: true do |t|
    t.integer  "pool_id"
    t.integer  "round_id"
    t.float    "pool_hash_rate_mhs", default: 0.0
    t.integer  "workers_count",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pool_histories", ["created_at"], name: "index_pool_histories_on_created_at"
  add_index "pool_histories", ["pool_hash_rate_mhs"], name: "index_pool_histories_on_pool_hash_rate_mhs"
  add_index "pool_histories", ["pool_id"], name: "index_pool_histories_on_pool_id"
  add_index "pool_histories", ["round_id"], name: "index_pool_histories_on_round_id"
  add_index "pool_histories", ["workers_count"], name: "index_pool_histories_on_workers_count"

  create_table "pools", force: true do |t|
    t.integer  "coin_id",                                  null: false
    t.string   "url"
    t.string   "daemon"
    t.boolean  "is_active"
    t.string   "dir"
    t.boolean  "is_profit_switch"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "calculated_hash_rate_mhs"
    t.integer  "type_of",                  default: 0
    t.integer  "state",                    default: 0
    t.boolean  "is_online",                default: false
  end

  add_index "pools", ["coin_id"], name: "index_pools_on_coin_id"
  add_index "pools", ["is_profit_switch", "is_active"], name: "index_pools_on_is_profit_switch_and_is_active"

  create_table "profit_switches", force: true do |t|
    t.integer "pool_id"
    t.string  "decision"
  end

  add_index "profit_switches", ["pool_id"], name: "index_profit_switches_on_pool_id"

  create_table "profitability_analytics", force: true do |t|
    t.decimal  "vwap"
    t.integer  "rating"
    t.integer  "pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "round_id"
  end

  add_index "profitability_analytics", ["pool_id"], name: "index_profitability_analytics_on_pool_id"
  add_index "profitability_analytics", ["round_id"], name: "index_profitability_analytics_on_round_id"

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 5
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories"

  create_table "redemptions", force: true do |t|
    t.integer  "user_id"
    t.integer  "coin_id"
    t.float    "amount"
    t.string   "address"
    t.datetime "finished"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tx_hash"
    t.integer  "state",      default: 0
    t.string   "message"
  end

  add_index "redemptions", ["coin_id"], name: "index_redemptions_on_coin_id"
  add_index "redemptions", ["state"], name: "index_redemptions_on_state"
  add_index "redemptions", ["user_id"], name: "index_redemptions_on_user_id"

  create_table "relays", force: true do |t|
    t.string   "url"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "revenues", force: true do |t|
    t.integer  "round_id"
    t.float    "amount"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  create_table "rounds", force: true do |t|
    t.decimal  "shares"
    t.integer  "hash_rate_mhs"
    t.integer  "workers"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "accepted"
    t.integer  "rejected"
    t.float    "reject_rate"
    t.integer  "pool_id",                   null: false
    t.integer  "state",         default: 0
  end

  add_index "rounds", ["end"], name: "index_rounds_on_end"
  add_index "rounds", ["pool_id"], name: "index_rounds_on_pool_id"
  add_index "rounds", ["start"], name: "index_rounds_on_start"

  create_table "trades", force: true do |t|
    t.integer  "order_id",         null: false
    t.float    "fee"
    t.float    "total_btc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "quantity"
    t.float    "price"
    t.integer  "cryptsy_trade_id"
  end

  add_index "trades", ["cryptsy_trade_id"], name: "index_trades_on_cryptsy_trade_id"
  add_index "trades", ["order_id"], name: "index_trades_on_order_id"

  create_table "user_coin_settings", force: true do |t|
    t.integer  "user_id",                   null: false
    t.integer  "coin_id",                   null: false
    t.boolean  "is_auto_trading"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "internal_exchange_address"
    t.string   "payout_address"
  end

  add_index "user_coin_settings", ["coin_id"], name: "index_user_coin_settings_on_coin_id"
  add_index "user_coin_settings", ["user_id", "coin_id"], name: "index_user_coin_settings_on_user_id_and_coin_id"
  add_index "user_coin_settings", ["user_id"], name: "index_user_coin_settings_on_user_id"

  create_table "user_leaderboards", force: true do |t|
    t.integer  "user_id"
    t.float    "earnings_btc"
    t.integer  "shares"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_leaderboards", ["user_id"], name: "index_user_leaderboards_on_user_id", unique: true

  create_table "user_pin_resets", force: true do |t|
    t.integer  "user_id"
    t.string   "code"
    t.boolean  "used",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_pin_resets", ["code"], name: "index_user_pin_resets_on_code", unique: true
  add_index "user_pin_resets", ["user_id"], name: "index_user_pin_resets_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                            default: "",    null: false
    t.string   "encrypted_password",               default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",                         default: false
    t.string   "username"
    t.string   "pin",                    limit: 4,                 null: false
    t.boolean  "is_enabled",                       default: false
    t.string   "gauth_secret"
    t.string   "gauth_enabled",                    default: "f"
    t.string   "gauth_tmp"
    t.datetime "gauth_tmp_datetime"
    t.float    "btc_threshold"
    t.float    "ltc_threshold"
  end

  add_index "users", ["created_at"], name: "index_users_on_created_at"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

  create_table "withdrawals", force: true do |t|
    t.integer  "coin_id"
    t.float    "amount"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "withdrawals", ["coin_id"], name: "index_withdrawals_on_coin_id"

  create_table "worker_credits", force: true do |t|
    t.integer  "round_id",        null: false
    t.integer  "worker_id",       null: false
    t.integer  "accepted_shares"
    t.integer  "rejected_shares"
    t.decimal  "reject_rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worker_credits", ["round_id", "worker_id"], name: "index_worker_credits_on_round_id_and_worker_id"
  add_index "worker_credits", ["round_id"], name: "index_worker_credits_on_round_id"
  add_index "worker_credits", ["worker_id"], name: "index_worker_credits_on_worker_id"

  create_table "worker_histories", force: true do |t|
    t.integer  "worker_id"
    t.integer  "round_id"
    t.float    "hash_rate_mhs", default: 0.0
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worker_histories", ["round_id"], name: "index_worker_histories_on_round_id"
  add_index "worker_histories", ["worker_id"], name: "index_worker_histories_on_worker_id"

  create_table "workers", force: true do |t|
    t.integer  "user_id",                              null: false
    t.float    "hash_rate_mhs"
    t.boolean  "is_active"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "send_notifications"
    t.string   "notification_interval"
    t.string   "username",                             null: false
    t.integer  "pool_id"
    t.boolean  "is_enabled",            default: true
  end

  add_index "workers", ["user_id"], name: "index_workers_on_user_id"
  add_index "workers", ["username"], name: "index_workers_on_username", unique: true

end
