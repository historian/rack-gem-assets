require 'rack/gem_assets'

stack = ActionController::Dispatcher.middleware
unless stack.any? { |middleware| ::Rack::GemAssets === middleware }
  stack.insert_before(Rails::Rack::Metal, ::Rack::GemAssets)
end