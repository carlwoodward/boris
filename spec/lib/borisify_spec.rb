require 'spec_helper'

describe 'servers' do
  include Borisify
  include Commands
  
  def test_connection_is_working
    add_server :test, '123.123.123.123', 'deploy', 'test'
    @connection = mock('connection')
    Net::SSH.should_receive(:start).with('123.123.123.123', 'deploy', :password => 'test').and_yield(@connection)
  end
  
  it "should connect to a server and exec something" do
    test_connection_is_working
    @connection.should_receive(:exec!).with("echo test | sudo -S /etc/init.d/apache2 restart").and_return('.done')
    setup :test do
      restart_apache
    end
  end
  
  it "should write out a config file" do
    configs_path File.dirname(__FILE__) + '/../configs_test'
    test_connection_is_working
    @connection.should_receive(:exec!).with("echo test | sudo -S echo 'test line 1' >> /etc/nginx/nginx.conf").exactly(3).times
    file_data = File.read(File.dirname(__FILE__) + '/../configs_test/nginx.erb')
    @connection.should_receive(:exec!).with("echo test | sudo -S ls /etc/nginx/nginx.conf").twice.and_return("No such file or directory")
    @connection.should_receive(:exec!).with("echo test | sudo -S cat /etc/nginx/nginx.conf").and_return(file_data)
    setup :test do
      write_config 'nginx', '/etc/nginx/nginx.conf'
    end
  end
  
  it "should check that a file exists" do
    test_connection_is_working
    @connection.should_receive(:exec!).with("echo test | sudo -S ls /etc/nginx/nginx.conf").and_return("No such file or directory")
    setup :test do
      has_file?('/etc/nginx/nginx.conf')
    end
  end
  
  it "should backup a file" do
    test_connection_is_working
    @connection.should_receive(:exec!).with("echo test | sudo -S cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf#{Time.now.to_i}")
    setup :test do
      backup_file('/etc/nginx/nginx.conf')
    end
  end
  
  it "should move directories" do # NOTE: no sudo
    test_connection_is_working
    @connection.should_receive(:exec!).with("cd /usr/local; ls -la")
    setup :test do
      in_directory("/usr/local") do
        run 'ls -la'
      end
    end
  end
  
end