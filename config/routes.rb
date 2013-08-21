Failcascade::Application.routes.draw do
  root to: 'landing#index'

  get '/about', to: 'landing#about', as: :about

  resources :alliances, only: [:index, :show], constraints: { id: /.*/ } do
    get :top_list, on: :collection
    get :growing, on: :collection
    get :collapsing, on: :collection
  end
end
