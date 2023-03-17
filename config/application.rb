require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ETENDART
  class Application < Rails::Application
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #

    config.time_zone = 'Paris'
    config.i18n.default_locale = :fr
    config.i18n.available_locales = [:fr, :en]
    # config.eager_load_paths << Rails.root.join("extras")

    Cloudinary.config do |config|
      config.cloud_name = 'dushuxqmj'
      config.api_key = ENV['CLOUDINARY_API_KEY']
      config.api_secret = ENV['CLOUDINARY_API_SECRET']
      config.secure = true
      config.cdn_subdomain = true
    end

    preset_name = "student_avatar"
    preset_options = {
      unsigned: true,
      folder: "etendart/students/avatars",
      transformation: [
        { width: 200, quality: "auto", crop: "scale"}
      ]
    }

    preset = Cloudinary::Api.get_upload_preset(preset_name)

    if preset["error"] == "not_found"
      # Le preset n'existe pas, on le crée
      Cloudinary::Api.create_upload_preset(name: preset_name, **preset_options)
    else
      # Le preset existe, on le met à jour
      Cloudinary::Api.update_upload_preset(name: preset_name, **preset_options)
    end
  end
end
