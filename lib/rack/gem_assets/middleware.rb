class Rack::GemAssets::Middleware
  
  F = ::File
  
  # :assets_dir:: the sub directory where we will look for assets. (default: <tt>public</tt>)
  # :xsendfile:: use XSendfile to send files.(default: <tt>true</tt>)
  def initialize(app, options={})
    @app      = app
    @options  = { :assets_dir => 'public', :xsendfile => true }.merge(options)
    @resolver = Rack::GemAssets::Resolver.new(:assets_dir => @options[:assets_dir])
    
    @asset_sizes ||= {}
    @asset_mimes ||= {}
  end
  
  def call(env)
    unless env["REQUEST_METHOD"].to_s == 'GET'
      return pass env
    end
    
    path = Rack::Utils.unescape(env["PATH_INFO"])
    if path.include?("..") or path.include?("~")
      return pass env
    end
    
    full_path = @resolver.resolve(path)
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
  
end
