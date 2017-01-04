Rails.application.routes.draw do
  get 'grades/gradeexport' => "grades#gradeexport"
  #get 'grades/stugradeexport' => "grades#stugradeexport"
  
  get 'password_resets/new'

  get 'password_resets/edit'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root 'homes#index'
 
  resources :courses do
    member do
      get :selectasPT
      get :selectasdegree
      get :selectasnondegree
      get :quit
      get :open
      get :close
      get :courseplan
      get :courseaim
      get :coursecontent
      get :courseteacher
      get :courseplan
      get :modifydegree
      get :studentlist
      get :stuexport
      post :import
    end
    collection do
      get :list
      get :credittips
      get :filter
      get :course_schedule
      
    end
  end
 
  
  #添加账户激活需要的路由
  resources :account_activations, only: [:edit]
  #添加密码重置需要的路由
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :account_activations, only: [:edit]
 
  resources :grades do
    member do
      
     end
    collection do
      get :evaluate
      get :stugradeexport
      
    end
  end
  resources :users 

  get 'sessions/login' => 'sessions#new'
  post 'sessions/login' => 'sessions#create'
  
  delete 'sessions/logout' => 'sessions#destroy'
  
  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
