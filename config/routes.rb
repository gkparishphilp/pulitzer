Pulitzer::Engine.routes.draw do

	resources :articles, path: Pulitzer.article_path

	get "#{Pulitzer.article_path}/by/:id", to: 'articles#by_author'
	get "#{Pulitzer.article_path}/in/:id", to: 'articles#in_category'
	get "#{Pulitzer.article_path}/tagged/:id", to: 'articles#tagged'

	resources :article_admin, path: 'blog_admin' do
		get :preview, on: :member
		delete :empty_trash, on: :collection
	end

	resources :attachments, only: [:create,:destroy,:index]

	resources :category_admin

	resources :content_section_admin

	resources :page_admin do
		put :clone, on: :member
		get :preview, on: :member
		delete :empty_trash, on: :collection
	end

	resources :redirect_admin

	resources :site_admin

	resources :site_asset_admin

	resources :version_admin do
		put :restore, on: :member
		put :undo, on: :member
	end

	# resources :user_admin

end
