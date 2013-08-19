Failcascade::Application.routes.draw do
  root to: 'landing#index'
  resources :alliances, only: [:index, :show] do
    get :top, on: :collection
    get :growing, on: :collection
    get :collapsing, on: :collection
  end
end
