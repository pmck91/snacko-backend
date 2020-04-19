Rails.application.routes.draw do

  # recipes
  get '/recipes', to: 'recipes#index'
  get '/recipes/category/:tag', to: 'recipes#by_tag'
  get '/recipes/:slug', to: 'recipes#show', as: 'recipe'
  post '/recipes', to: 'recipes#create'
  patch '/recipes/:id', to: 'recipes#update', as: 'update_recipe'
  delete '/recipes/:id', to: 'recipes#destroy', as: 'destroy_recipe'

  # tags
  get '/tags/', to: 'tags#index'

  # users
  resources :users
  post 'user_token' => 'user_token#create'
  post '/user/find' => 'users#find'

end
