# desc "Explaining what the task does"
namespace :pulitzer do
	task :install do
		puts "Installing Pulitzer. Who, What, When, Where, Why?"

		files = {
					'root_controller.rb' => 'app/controllers',
					'application_controller.rb' => 'app/controllers',
					'admin.html.haml' => 'app/views/layouts',
					'application.html.haml' => 'app/views/layouts',
					'_gtm_head.html.erb' => 'app/views/application',
					'_gtm_body.html.erb' => 'app/views/application',
					'_navbar.html.haml' => 'app/views/application',
					'_footer.html.haml' => 'app/views/application',
					'storage.yml' => 'config',
					'route_downcaser.rb' => 'config/initialiers',
		}

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

	end

end
