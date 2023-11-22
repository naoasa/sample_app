Rails.application.routes.draw do
  root   "static_pages#home"
  get    "/help",     to: "static_pages#help"
  get    "/about",    to: "static_pages#about"
  get    "/contact",  to: "static_pages#contact"
  get    "/signup",   to: "users#new"
  get    "/login",    to: "sessions#new"
  post   "/login",    to: "sessions#create"
  delete "/logout",   to: "sessions#destroy"
  resources :users
  resources :account_activations, only: [:edit] # 名前付きルーティング"edit_account_activation_url(token)"が使えるようになる
end
