Rails.application.routes.draw do
  root to: "application#index"
  # blacklight_for :catalog

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    get '/sign_in', to: 'users/sessions#new', as: :new_user_session
    get '/sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end
  
  # Persons Collection
  get '/persons(/:page)', to: 'persons#index', as: :persons
  post '/persons(/:page)', to: 'persons#search'

  # Person
  resources :person, only: [:show, :create, :destroy] do
    # Person Accounts
    resources :account, only: [:create, :destroy]
    put '/account/:id', to: 'account#update'

    # Person Memberships
    resources :membership, only: [:create, :destroy], controller: 'person/membership'
    put '/membership/:id', to: 'person/membership#update'

    # Person ORCID Accounts convenience function
    get '/orcid', to: 'person/account#orcid', as: :orcid

    # Person's Works Collection
    get '/works(/:start_date)', to: 'person/works#index', as: :works,
        constraints: { start_date: /\d{4}-\d{2}-\d{2}/ }
  end
  put '/person/:id', to: 'person#update'

  # Recent Works Collections convenience function
  get '/works/:start_date(/:page)', to: 'works#index', start_date: /\d{4}-\d{2}-\d{2}/,
      page: /\d+/
  post '/works/:start_date(/:page)', to:'works#search', start_date: /\d{4}-\d{2}-\d{2}/,
       page: /\d+/

  # Works Collection
  get '/works(/:page)', to: 'works#index', page: /\d+/
  post '/works(/:page)', to: 'works#search', page: /\d+/

  # Work
  resources :work, only: [:show, :create, :destroy] do
    # Work License
    resources :license, only: [:create, :destroy], controller: 'work/license'
    put '/license/:id', to: 'work/license#update'
  end
  put '/work/:id', to: 'work#update'

  # Organizations Collection
  get '/organizations(/:page)', to: 'organizations#index', as: :organizations
  post '/organizations(/:page)', to: 'organizations#search'

  # Organization
  resources :organization, only: [:show, :create, :destroy] do
    resources :account, only: [:create, :destroy]
    put '/account/:id', to: 'account#update'
  end
  put '/organization/:id', to: 'organization#update'

  # Change Events

  # Redirects for html requests.
  get '/person', to: redirect('persons'), constraints: { format: 'html' }
  get '/work', to: redirect('works'), constraints: { format: 'html' }
  get '/organization', to: redirect('organizations'), constraints: { format: 'html' }
end
