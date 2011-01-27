
require 'rack/gem_assets'

namespace :assets do
  desc "Import all assets from other gems"
  task 'import' do
    resolver = Rack::GemAssets::Resolver.new
    public_dir = File.expand_path('public')
    
    resolver.assets.each do |target, source|
      target = public_dir + target
      next if File.exists?(target)
      
      begin
        FileUtils.mkdir_p(File.dirname(target))
        FileUtils.cp source, target
      rescue
        # ignore
      end
      
    end
  end
end
