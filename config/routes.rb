Failcascade::Application.routes.draw do
  root to: 'alliances#index'
  get '/:ticker', to: 'alliances#show', as: :alliance, constraints: { ticker: /.*/ }
end
