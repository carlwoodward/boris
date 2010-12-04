# Boris - Because Boris can't cook!

Boris is a small simple devops management gem. All config can be done in one file. Sharing deployment packages is as requiring some code. It takes ideas from sprinkle and adds config files to the mix. Only supports ubuntu at the moment, but you already use that don't you.

Lets look at some code:

    servers :staging => ['192.168.0.1'], :live => ['192.168.0.2', '192.168.0.3']
    setup :staging, :live do
      # Web Server
      apt_get_install 'nginx'
      config_file 'nginx.erb', '/etc/nginx/nginx.conf', :locals => {:server_name => 'test.com', :root => '/somewhere/public'}
    end
    
And then defining a config file __nginx.erb__:

    server {
      listen 80;
      server_name <%= server_name %>;
      root <%= root %>;
      passenger_enabled on;
    }