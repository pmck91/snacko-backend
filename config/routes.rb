Rails.application.routes.draw do

  # tags
  get 'tags/', to: 'tags#index'

  # recipes
  get '/recipes', to: 'recipes#index'
  get '/recipes/category/:tag', to: 'recipes#by_tag'
  get '/recipes/:slug', to: 'recipes#show', as: 'recipe'
  post '/recipes', to: 'recipes#create'
  delete '/recipes/:id', to: 'recipes#delete', as: 'delete_recipe'

end
