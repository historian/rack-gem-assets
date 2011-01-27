# Rack GemAssets

This is a Rack Middleware which will find and send static files provided by loaded gems.

### Asset search rules

1. if the path starts with `/vendor/:name` (eg: `/vendor/my-assets-gem/image.jpg`)
   we will look for a loaded gem called `:name` and find a file in there first.
   Otherwise we search each loaded gems.
2. For each gem in our search list we will look in the `:assets_dir` directory under the `full_gem_path` (next to the lib dir).
   if this directory contains a file with the specified path we send it.
3. if the path ends with a slash we remove it. then we append `.html`
   (eg: `/pages/about/ => /pages/about.html`, `/pages/about => /pages/about.html`)
4. If we still dont have a match we append `/index.html`
   (eg: `/pages/about/ => /pages/about/index.html`, `/pages/about => /pages/about/index.html`)
5. If we still don't have a match we pass the request to the sub app.

### Configuration

* `:assets_dir`: the sub directory where we will look for assets. (default: `public`)
* `:xsendfile`: use X-Sendfile to send files.(default: `true`)

### Rails Configuration

    config.gem "rack-gem-assets", :source => "http://gemcutter.org"
    config.middleware.use "Rack::GemAssets::Middleware", :assets_dir => 'public', :xsendfile => false

### X-Sendfile Configuration

Your apache config needs to include these configuration directives:

    XSendFile           On # enable X-Sendfile
    XSendFileAllowAbove On # allow X-Sendfile to access files outside of the Directory

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
  bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2009 Simon Menke. See LICENSE for details.
