Hashbros::Application.routes.draw do

  # Rails Admin
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # Monologue Blog
  mount Monologue::Engine => '/blog'

  # API
  mount API => '/api', :as => 'api'

  # Devise
  devise_for :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # Home
  get 'dashboard' => 'home#dashboard'
  get 'FAQ' => 'home#faq'
  get 'contact' => 'home#contact'
  get 'settings' => 'users#settings'
  get 'leaderboard' => 'home#leaderboard'
  get 'profitability' => 'home#profitability', :as => 'profitability'
  get 'developers' => 'home#developers'
  get 'metrics' => 'home#metrics', :as => 'metrics'

  # Users
  get '/users/:user_id/rounds' => 'users#rounds'
  get '/users/load_setting/:coin_id' => 'users#load_setting'
  post '/users/update_coin_settings' => 'users#update_coin_settings', :as => 'update_coin_settings'
  post '/users/update_redemption_settings' => 'users#update_redemption_settings', :as => 'update_redemption_settings'
  post '/users/update_auto_trade_settings' => 'users#update_auto_trade_settings', :as => 'update_auto_trade_settings'
  post '/users/settings/edit' => 'users#save_settings', :as => 'edit_user_coin_settings'

  post '/users/dashboard-info' => 'users#get_user_dashboard_info', :as => 'get_user_dashboard_info'
  get '/users/settings/security' => 'users#security', :as => 'user_settings_security'
  get '/users/settings/security/pin' => 'users#edit_pin', :as => 'edit_pin'
  get '/users/settings/security/pin/forgot' => 'users#forgot_pin', :as => 'forgot_pin'
  post '/users/settings/security/pin/reset' => 'users#reset_pin', :as => 'reset_pin'
  get '/users/settings/security/pin/reset/:code' => 'users#reset_pin_form', :as => 'reset_pin_form'
  post '/users/settings/security/pin/set' => 'users#set_pin', :as => 'set_pin'
  post '/users/settings/security/pin/update' => 'users#update_pin', :as => 'update_pin'
  post '/users/settings/security/2fa/check' => 'users#test_2fa', :as => 'test_2fa'
  post '/users/reauthenticate' => 'users#reauthenticate', :as => 'reauthenticate'
  post '/users/load-reauthenticate-modal' => 'users#load_reauthenticate_modal', :as => 'load_reauthenticate_modal'
  get '/users/notifications/mark-all-as-read' => 'notifications#mark_all_as_read'
  get '/notifications' => 'notifications#all', :as => 'all_notifications'
  post '/notifications/poll' => 'notifications#poll', :as => 'notifications_poll'
  get '/users/accept/all-for-beta' => 'users#accept_all_for_beta'

  # Management Backend
  get 'manage' => 'manage#index'
  get 'manage/deposits' => 'manage#deposits'
  get 'manage/rounds' => 'manage#rounds'
  get 'manage/redemptions' => 'manage#redemptions'
  get 'manage/redemptions/:id/process' => 'manage#process_redemption'
  get 'manage/revenues' => 'manage#revenues'

  # Accepting users
  get '/users/accept/:id' => 'users#accept_user'

  # Earnings
  #get '/earnings/all' => 'home#earnings'
  get '/earnings' => 'users#earnings'
  get '/redemptions' => 'users#redemptions'
  get '/payouts/all' => 'home#payouts'
  post '/payouts/redeem/' => 'users#redeem'

  get '/payouts' => 'users#payouts'
  get '/deposits/all' => 'home#deposits'
  get '/deposits' => 'users#deposits'
  get '/getting-started/' => 'home#getting_started'

  # Debts
  get '/debts/redeem/:id' => 'debts#redeem'

  # Profitability Analytics
  get '/profitability-analytics' => 'profitability_analytics#index'

  # Override errors
  if Rails.env.production?
    get '/404', :to => "errors#error_404"
    post '/404', :to => "errors#error_404"
    get "/422", :to => "errors#error_404"
    post "/422", :to => "errors#error_404"
    get "/500", :to => "errors#error_500"
    post "/500", :to => "errors#error_500"
  end

  resources :users
  resources :rounds
  resources :coins
  resources :pools
  resources :workers
  resources :debts
  resources :withdrawals
  resources :coin_histories

  root 'home#index'

end
