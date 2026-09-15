Rails.application.routes.draw do
  namespace :admin do
    root "dashboard#show"

    resource :session, only: %i[new create destroy]

    resources :pages do
      member do
        patch :publish
        patch :unpublish
      end
      resources :sections, only: %i[new create] do
        patch :reorder, on: :collection
      end
    end

    resources :sections, only: %i[edit update destroy] do
      member do
        patch :move_up
        patch :move_down
        patch :toggle
      end
      resources :section_items, only: %i[new create], path: "elements" do
        patch :reorder, on: :collection
      end
    end

    resources :section_items, only: %i[edit update destroy], path: "elements" do
      member do
        patch :move_up
        patch :move_down
      end
    end

    resources :media_items, only: %i[index new create edit update destroy], path: "medias"
    resources :form_submissions, only: %i[index show update destroy], path: "demandes"
    resource  :site_setting, only: %i[edit update], path: "reglages"
  end

  resources :form_submissions, only: :create, path: "demandes"

  get "sitemap.xml", to: "sitemaps#show", as: :sitemap, defaults: { format: :xml }
  get "up", to: "rails/health#show", as: :rails_health_check

  root "pages#show"
  get "/:slug", to: "pages#show", as: :page, constraints: { slug: /[a-z0-9][a-z0-9\-]*/ }
end
