# Boris - Because Boris can't cook!

__Boris in the really early stages of development. Use at your own risk.__

Boris is a small simple devops management gem. All config can be done in one file. Sharing deployment packages is as simple as requiring a file and including the module.

Lets look at some code:

    add_server :test, '123.123.123.123', 'deploy', 'test'
    setup :staging, :live do |role|
      # Web Server
      apt_get_install 'nginx'
      write_config 'nginx', '/etc/nginx/nginx.conf', :locals => {:server_name => 'test.com', :root => '/somewhere/public'}
    end
    
And then defining a config file __nginx.erb__:

    server {
      listen 80;
      server_name <%= server_name %>;
      root <%= root %>;
      passenger_enabled on;
    }
    
Right now passwords are kept in the config file. Does anyone have a problem with this? Should it prompt you?