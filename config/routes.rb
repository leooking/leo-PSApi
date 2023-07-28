# frozen_string_literal: true

Rails.application.routes.draw do

  get 'dashboard',    to: 'dashboard#show'

  get 'data_sources/opportunities', to: 'data_sources#opportunities'
  get 'data_sources/naics_codes', to: 'data_sources#naics_codes'

  get 'resources', to: 'resources#index2'
  get 'assetz', to: 'assetz#index2'
  get 'assetz/recent', to: 'assetz#recent'
  get 'projects', to: 'projects#index2'
  get 'agencies', to: 'agencies#index'
  get 'states', to: 'states#index'

  resources :projects do
    post 'add_team_member',     on: :member
    post 'remove_team_member',  on: :member
    get 'resources',            on: :member
    get 'available_users',      on: :member
    post 'attach_resource',     on: :member
    post 'detach_resource',     on: :member
    post 'add_note',            on: :member
    post 'remove_note',         on: :member
    post 'create_new_location', on: :member
    post 'relocate_object',     on: :member
    post 'unfolder',            on: :member
    post 'request_access',      on: :member
  end

  resources :assetz do
    post 'autosave',                on: :member
    post 'interaction',             on: :member
    post 'attach_to_project',       on: :member
    post 'set_project_attachments', on: :member
    post 'add_to_favorites',        on: :member
    post 'remove_from_favorites',   on: :member
    post 'create_new_location',     on: :member
    post 'relocate_object',         on: :member
    post 'unfolder',                on: :member
    post 'convert_to_org_scope',    on: :member
    post 'create_revision',         on: :member
  end

  resources :asset_interactions, only: [:update]

  post  'crawl/result',         to: 'crawl#result'

  resources :generators, to: 'asset_generators#index', only: [:index]

  resources :folders, except: [:new, :edit] do
    post 'relocate_folder',         on: :member
    post 'unfolder',                on: :member
  end

  resources :resources do
    post 'bulk_upload',               on: :collection
    get 'resource_crawl',             on: :member
    get 'tag_list',                   on: :collection
    post 'filtered_results',          on: :collection
    post 'set_project_attachments',   on: :member
    post 'add_note',                  on: :member
    post 'remove_note',               on: :member
    post 'create_new_location',       on: :member
    post 'relocate_object',           on: :member
    post 'unfolder',                  on: :member
  end

  resources :user_notifications, only: [:index, :destroy] do
    post 'mark_as_read', on: :member
  end

  resources :notes, only: %i[update destroy]

  resources :prompts do
    post 'add_to_favorites', on: :member
    post 'remove_from_favorites', on: :member
  end

  post 'api_calls/new_request', to: 'api_calls#new_request'
  post 'api_calls/result', to: 'api_calls#result'

  root to: 'static#root'

  resources :groups, only: [:index, :show, :create, :update, :destroy] do
    post 'add_user', on: :member
    post 'remove_user', on: :member
    post 'bulk_add', on: :member
  end

  scope :session do
    get 'valid_email', to: 'session#valid_email'
    get 'auth', to: 'session#auth'
    post 'email', to: 'session#email'
    post 'password', to: 'session#password'
    post 'verify_otp', to: 'session#verify_otp'
    post 'reset_request', to: 'session#reset_request'
    post 'password_reset', to: 'session#password_reset'
    post 'token_refresh', to: 'session#token_refresh'
  end

  scope :auth0 do
    post '/verify' => 'auth0#token_verification'
  end

  scope :webhooks do
    post 'stripe_checkout', to: 'webhooks#stripe_checkout'
    post 'stripe_payment_success', to: 'webhooks#stripe_payment_success'
    post 'stripe_cancel', to: 'webhooks#stripe_cancel'
    post 'stripe_payment_failure', to: 'webhooks#stripe_payment_failure'
  end

  scope :customers do
    get 'dashboard', to: 'customers#dashboard'
    
    get 'groups', to: 'customers#groups'
    post 'group_management', to: 'customers#group_management'
    
    get 'users', to: 'customers#users'
    put 'update_user', to: 'customers#update_user'
    post 'add_user', to: 'customers#add_user'
    post 'add_bulk_user', to: 'customers#add_bulk_user'
    
    get 'licenses', to: 'customers#licenses'
    scope :licenses do
      get 'summary', to: 'customers#licenses_summary'
    end

  end

  put 'users/verify_email', to: 'users#verify_email'
  resources :users, only: %i[show update] do
    post 'activate_in_group', on: :member
    get 'resend_verification_email', to: 'users#resend_verification_email'
  end

  post 'staff/prov151on', to: 'staff#prov151on'
  get 'psci_echo', to: 'static#psci_echo'

  resources :pipelines, only: [:index, :create, :destroy, :update] do
    member do
      put 'pipeline_stage'
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

end
