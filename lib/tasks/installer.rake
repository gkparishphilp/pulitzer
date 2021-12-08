# desc "Explaining what the task does"
namespace :pulitzer do
	task :install_rails5 do
		puts "Installing Pulitzer. Who, What, When, Where, Why?"

		files = {
					'root_controller.rb' => 'app/controllers',
					'application_controller.rb' => 'app/controllers',
					'admin_controller.rb' => 'app/controllers',
					'admin.js' => 'app/javascript',
					'admin.css' => 'app/javascript/packs/stylesheets',
					'admin.html.haml' => 'app/views/layouts',
					'application.html.haml' => 'app/views/layouts',
					'_gtm_head.html.erb' => 'app/views/partials/plugins',
					'_gtm_body.html.erb' => 'app/views/partials/plugins',
					'_flash.html.haml' => 'app/views/partials/ui',
					'_navbar.html.haml' => 'app/views/partials/ui',
					'_footer.html.haml' => 'app/views/partials/ui',
					'storage.yml' => 'config',
					'route_downcaser.rb' => 'config/initialiers',
					'index.html.haml' => 'app/views/root',
					'admin' => 'app/views',
		}

		FileUtils::mkdir_p( File.join( Rails.root, 'app/views/partials' ) )
		FileUtils::mkdir_p( File.join( Rails.root, 'app/views/partials/ui' ) )
		FileUtils::mkdir_p( File.join( Rails.root, 'app/views/partials/plugins' ) )
		FileUtils::mkdir_p( File.join( Rails.root, 'app/views/root' ) )
		FileUtils::mkdir_p( File.join( Rails.root, 'config/initialiers' ) )

		files.each do |filename, path|
			puts "installing: #{path}/#{filename}"

			source = File.join( Gem.loaded_specs["pulitzer"].full_gem_path, "lib/tasks/install_files", filename )
    		if path == :root
    			target = File.join( Rails.root, filename )
    		else
    			target = File.join( Rails.root, path, filename )
    		end
    		FileUtils.cp_r source, target
		end


		# migrations

		FileUtils::mkdir_p( File.join( Rails.root, 'db/migrate/' ) )


		migrations = [
			'pulitzer_migration.rb',
			'pulitzer_active_storage_migration.rb',
		]

		prefix = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i

		migrations.each do |filename|

			puts "installing: db/migrate/#{prefix}_#{filename}"

			source = File.join( Gem.loaded_specs["pulitzer"].full_gem_path, "lib/tasks/install_files", filename )

    		target = File.join( Rails.root, 'db/migrate', "#{prefix}_#{filename}" )

    		FileUtils.cp_r source, target
    		prefix += 1
		end

		new_contents = File.read(File.join( Rails.root, 'config/routes.rb' ))
		new_contents = new_contents.gsub(/^Rails\.application\.routes\.draw do\n/, "Rails.application.routes.draw do\n\troot to: 'root#index' # homepage\n")
		new_contents = new_contents.gsub(/^end/, "\tmount Pulitzer::Engine, at: '/'\n\n\t# quick catch-all route for static pages set root route to field any media\n\tget '/:id', to: 'root#show', as: 'root_show'\nend")
	  File.open(File.join( Rails.root, 'config/routes.rb' ), "w") {|file| file.puts new_contents }

	end

	task :install do
		puts "Installing Pulitzer. Who, What, When, Where, Why?"

		files = {
					'root_controller.rb' => 'app/controllers',
					'application_controller.rb' => 'app/controllers',
					'admin_controller.rb' => 'app/controllers',
					'admin.js' => 'app/assets/javascripts',
					'admin.css' => 'app/assets/stylesheets',
					'admin.html.haml' => 'app/views/layouts',
					'application.html.haml' => 'app/views/layouts',
					'_gtm_head.html.erb' => 'app/views/partials/plugins',
					'_gtm_body.html.erb' => 'app/views/partials/plugins',
					'_flash.html.haml' => 'app/views/partials/ui',
					'_navbar.html.haml' => 'app/views/partials/ui',
					'_footer.html.haml' => 'app/views/partials/ui',
					'storage.yml' => 'config',
					'route_downcaser.rb' => 'config/initialiers',
					'index.html.haml' => 'app/views/root',
					'admin' => 'app/views',
		}

		FileUtils::mkdir_p( File.join( Rails.root, 'app/views/partials' ) )
		FileUtils::mkdir_p( File.join( Rails.root, 'app/views/partials/ui' ) )
		FileUtils::mkdir_p( File.join( Rails.root, 'app/views/partials/plugins' ) )
		FileUtils::mkdir_p( File.join( Rails.root, 'app/views/root' ) )
		FileUtils::mkdir_p( File.join( Rails.root, 'config/initialiers' ) )

		files.each do |filename, path|
			puts "installing: #{path}/#{filename}"

			source = File.join( Gem.loaded_specs["pulitzer"].full_gem_path, "lib/tasks/install_files", filename )
    		if path == :root
    			target = File.join( Rails.root, filename )
    		else
    			target = File.join( Rails.root, path, filename )
    		end
    		FileUtils.cp_r source, target
		end


		# migrations

		FileUtils::mkdir_p( File.join( Rails.root, 'db/migrate/' ) )


		migrations = [
			'pulitzer_migration.rb',
			'pulitzer_active_storage_migration.rb',
		]

		prefix = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i

		migrations.each do |filename|

			puts "installing: db/migrate/#{prefix}_#{filename}"

			source = File.join( Gem.loaded_specs["pulitzer"].full_gem_path, "lib/tasks/install_files", filename )

    		target = File.join( Rails.root, 'db/migrate', "#{prefix}_#{filename}" )

    		FileUtils.cp_r source, target
    		prefix += 1
		end

		new_contents = File.read(File.join( Rails.root, 'config/routes.rb' ))
		new_contents = new_contents.gsub(/^Rails\.application\.routes\.draw do\n/, "Rails.application.routes.draw do\n\troot to: 'root#index' # homepage\n")
		new_contents = new_contents.gsub(/^end/, "\tmount Pulitzer::Engine, at: '/'\n\n\t# quick catch-all route for static pages set root route to field any media\n\tget '/:id', to: 'root#show', as: 'root_show'\nend")
	  File.open(File.join( Rails.root, 'config/routes.rb' ), "w") {|file| file.puts new_contents }

	end

end
