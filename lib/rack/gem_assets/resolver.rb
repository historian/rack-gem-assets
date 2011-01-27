class Rack::GemAssets::Resolver
  
  F = ::File
  
  # :assets_dir:: the sub directory where we will look for assets. (default: <tt>public</tt>)
  def initialize(options={})
    @options = { :assets_dir => 'public' }.merge(options)
  end
  
  def resolve(path)
    if path[-1,1] == '/'
      path = path[0..-2]
    end
    
    resolve_all_paths unless @assets
    
    @assets[path]
  end
  
  def assets
    @assets.dup
  end
  
  def reset!
    @assets = nil
  end
  
private

  def resolve_all_paths
    @assets = {}
    
    groups = [:default, Rails.env.to_s.to_sym]
    Bundler.definition.specs_for(groups).each do |spec|
      
      resolve_all_paths_in_spec(spec)
      
    end
  end
  
  def resolve_all_paths_in_spec(spec)
    public_dir = F.join(spec.full_gem_path, @options[:assets_dir])
    
    unless F.directory?(public_dir)
      return false
    end
    
    Dir.glob("#{public_dir}/**/*").each do |path|
      next unless F.file?(path) and F.readable?(path)
      
      rel_path = path.dup
      rel_path[0, public_dir.length] = ''
      
      @assets[rel_path] = path
      @assets["/vendor/#{spec.name}#{rel_path}"] = path
      
      if File.basename(path) == 'index.html'
        rel_path = rel_path.sub(/\/index\.html$/, '')
        @assets[rel_path] = path
        @assets["/vendor/#{spec.name}#{rel_path}"] = path
      end
      
      if File.extname(path) == '.html'
        rel_path = rel_path.sub(/\.html$/, '')
        @assets[rel_path] = path
        @assets["/vendor/#{spec.name}#{rel_path}"] = path
      end
      
    end
  end
  
end