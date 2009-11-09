require 'rubygems'

module Rack #:nodoc:
  class GemAssets
    
    F = ::File
    
    # :assets_dir:: the sub directory where we will look for assets. (default: <tt>public</tt>)
    # :xsendfile:: use XSendfile to send files.(default: <tt>true</tt>)
    def initialize(app, options={})
      @app     = app
      @options = { :assets_dir => 'public', :xsendfile => true }.merge(options)
      
      @public_dirs = {}
      @asset_paths = {}
      @asset_sizes = {}
      @asset_mimes = {}
    end
    
    def call(env)
      unless env["REQUEST_METHOD"].to_s
        return pass env
      end
      
      path = Rack::Utils.unescape(env["PATH_INFO"])
      if path.include?("..") or path.include?("~")
        return pass env
      end
      
      full_path = path_to_asset(path)
      if full_path
        return send_file full_path
      end
      
      return pass env
    end
    
  private
    
    def pass(env)
      @app.call(env)
    end
    
    def send_file(full_path)
      if @options[:xsendfile]
        [200, {
          'X-Sendfile'     => full_path,
          'Content-length' => size_for_asset(full_path).to_s,
          'Content-Type'   => mime_for_asset(full_path)
        }, []]
      else
        [200, {
          'Content-length' => size_for_asset(full_path).to_s,
          'Content-Type'   => mime_for_asset(full_path)
        }, [F.read(full_path)]]
      end
    end
    
    def size_for_asset(path)
      @asset_sizes[path] ||= F.size(path)
    end
    
    def mime_for_asset(path)
      @asset_mimes[path] ||= Rack::Mime.mime_type(F.extname(path))
    end
    
    def path_to_asset(path)
      return @asset_paths[path] if @asset_paths.key?(path)
      
      full_path = nil
      
      if path =~ %r{^/vendor/([^/]+)/(.+)$}
        full_path = path_to_asset_for_gem($2, $1)
        if full_path
          @asset_paths[path] = full_path
          return full_path
        end
      end
      
      Gem::loaded_specs.keys.each do |gem_name|
        full_path = path_to_asset_for_gem(path, gem_name)
        if full_path
          @asset_paths[path] = full_path
          return full_path
        end
      end
      
      @asset_paths[path] = full_path
      return full_path
    end
    
    def path_to_asset_for_gem(path, gem_name)
      public_dir = public_dir_for_gem(gem_name)
      return nil unless public_dir
      
      full_path = F.join(public_dir, path)
      
      if full_path[-1,1] == '/'
        full_path = full_path[0..-2]
      end
      
      if F.file?(full_path) and F.readable?(full_path)
        return full_path
      end
      
      html_path = full_path+".html"
      if F.file?(html_path) and F.readable?(html_path)
        return html_path
      end
      
      index_path = full_path+"/index.html"
      if F.file?(index_path) and F.readable?(index_path)
        return index_path
      end
      
      return nil
    end
    
    def public_dir_for_gem(gem_name)
      return @public_dirs[gem_name] if @public_dirs.key?(gem_name)
      
      spec = Gem::loaded_specs[gem_name]
      if spec
        public_dir = F.join(spec.full_gem_path, @options[:assets_dir])
        if F.directory?(public_dir)
          @public_dirs[gem_name] = public_dir
          return public_dir
        end
      end
      
      return nil
    end
    
  end
end
