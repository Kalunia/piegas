Piegas::Application.routes.draw do

  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  get 'home/index' => 'home#index'
  get 'project/index' => 'project#index'
  get 'project/pdf' => 'project#pdf'
  get 'project/posts' => 'project#posts'
  get 'project/charts' => 'project#charts'
  get 'project/spams' => 'project#spams'
  get 'project/favoriteds' => 'project#favoriteds'
  get 'project/about' => 'project#about'
  get 'project/profile' => 'project#profile'

  # GET para Action Controllers
  get 'project/refresh_posts' => 'project#refresh_posts'
  get 'project/get_pdf' => 'project#get_pdf'

  get 'project/add_spam' => 'project#add_spam'
  get 'project/add_favorited' => 'project#add_favorited'
  get 'project/delete_spams' => 'project#delete_spams'
  get 'project/delete_favoriteds' => 'project#delete_favoriteds'

  get 'project/create_barchart_png' => 'project#create_barchart_png'
  get 'project/create_piechart_png' => 'project#create_piechart_png'
 

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
