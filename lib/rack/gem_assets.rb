module Rack::GemAssets
  
  require "rack/gem_assets/version"
  require "rack/gem_assets/resolver"
  
  autoload :Middleware, 'rack/gem_assets/middleware'
  
end