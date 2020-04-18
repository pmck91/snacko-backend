Rails.application.routes.draw do

  get '/recipes', to: 'recipes#index'
  get '/recipes/:slug', to: 'recipes#show', as: 'recipe'

  post '/recipes', to: 'recipes#create'

  delete '/recipes/:id', to: 'recipes#delete', as: 'delete_recipe'

end
