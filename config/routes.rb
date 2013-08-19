Failcascade::Application.routes.draw do
  root to: 'landing#index'
  resources :alliances, only: [:index, :show], constraints: { id: /.*/ } do
    get :top_list, on: :collection
    get :growing, on: :collection
    get :collapsing, on: :collection
  end
end
