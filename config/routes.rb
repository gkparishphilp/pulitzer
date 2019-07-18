Pulitzer::Engine.routes.draw do

	resources :articles, path: Pulitzer.article_path
	resources :article_admin, path: 'blog_admin' do
		get :preview, on: :member
		delete :empty_trash, on: :collection
	end

	resources :attachments, only: [:create,:destroy,:index]

	resources 	:auto_link_admin

	resources :category_admin

	resources :content_section_admin

	resources :page_admin do
		put :clone, on: :member
		get :preview, on: :member
		delete :empty_trash, on: :collection
	end

	resources :redirect_admin

	resources :unattached_blob_admin

	resources :version_admin do
		put :restore, on: :member
		put :undo, on: :member
	end

	# resources :user_admin

end
