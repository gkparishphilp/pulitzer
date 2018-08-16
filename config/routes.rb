Pulitzer::Engine.routes.draw do

	resources :articles, path: Pulitzer.article_path
	resources :article_admin, path: 'blog_admin' do
		get :preview, on: :member
		delete :empty_trash, on: :collection
	end

	resources :category_admin

	resources :page_admin do
		put :clone, on: :member
		get :preview, on: :member
		delete :empty_trash, on: :collection
	end

	# resources :user_admin

end
