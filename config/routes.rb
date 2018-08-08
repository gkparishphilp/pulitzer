Pulitzer::Engine.routes.draw do
	root to: 'root#index' # homepage


	resources :articles, path: Pulitzer.article_path
	resources :article_admin, path: 'blog_admin' do
		get :preview, on: :member
		delete :empty_trash, on: :collection
	end

	resources :asset_manager, only: [ :new, :create, :destroy ] do
		post :callback_create, on: :collection
		get :callback_create, on: :collection
	end

	resources :asset_admin do
		delete :empty_trash, on: :collection
	end

	resources :browse

	resources :category_admin

	# resources :contacts do
	# 	get :thanks, on: :collection
	# end

	# resources :contact_admin

	# resources :optins, only: [:create] do
	# 	get :thank_you, on: :member, path: 'thank-you'
	# end

	resources :page_admin do
		put :clone, on: :member
		get :preview, on: :member
		delete :empty_trash, on: :collection
	end

	# resources :user_admin

	# quick catch-all route for static pages
	# set root route to field any media
	get '/:id', to: 'root#show', as: 'root_show'
end
