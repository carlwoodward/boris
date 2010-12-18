require 'net/ssh'
Net::SSH.start '184.106.172.137', 'root', :password => 'test6aA36AJol' do |ssh|
  ssh.exec "ls -la" do |ch, stream, data|
    ch.request_pty do |channel|
      if stream == :stderr
        puts "ERROR: #{data}"
      else
        puts data
      end
    end
  end
end