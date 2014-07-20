ChessCamp::Application.routes.draw do
  # generated routes
  resources :curriculums
  resources :instructors
  resources :camps
  resources :locations
  resources :students
  resources :families

  resources :users, only: [:create, :destroy]
  resources :sessions

  # semi-static routes
  get 'home', to: 'home#index', as: :home
  get 'home/about', to: 'home#about', as: :about
  get 'home/contact', to: 'home#contact', as: :contact
  get 'home/privacy', to: 'home#privacy', as: :privacy

  # set the root url
  root to: 'home#index'

  get 'login', to: 'home#index', as: :login
  get 'logout', to: 'sessions#destroy', as: :logout

  # get '*a', to: 'errors#routing'

  get 'camp_report/:id', to: 'camps#report', as: :camp_report
  get 'family_report/:id/', to: 'families#report', as: :family_report
  get 'family_report/:id/:year', to: 'families#yearly_report', as: :family_yearly_report

  get 'annual_report/:year/', to: 'home#annual_report', as: :annual_report
end
