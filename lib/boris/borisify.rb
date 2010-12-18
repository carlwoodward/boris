require 'net/ssh'
require 'erb'

class Boris
  attr_accessor :servers, :configs_path, :env_path
  
  def initialize
    self.servers = {}
    self.env_path = ''
  end
end

module Borisify
  def boris
    @boris ||= Boris.new
  end
  
  def add_server(role, ip_address, user, password)
    boris.servers[role] ||= []
    boris.servers[role] << {:ip_address => ip_address, :user => user, :password => password}
  end
  
  def user(user)
    boris.user = password
  end
  
  def password(password)
    boris.password = password
  end
  
  def current_connection=(connection)
    @current_connection = connection
  end
  
  def current_password=(password)
    @current_password = password
  end
  
  def current_password
    @current_password
  end
  
  def env_path(path)
    boris.env_path = path
  end
  
  def set_path
    boris.env_path == '' ? '' : "export PATH=#{boris.env_path}; "
  end
  
  def ssh
    @current_connection
  end
  
  def setup(*roles)
    roles.each do |role|
      boris.servers[role].each do |details|
        ip, user, password = details[:ip_address], details[:user], details[:password]
        Net::SSH.start ip, user, :password => password do |connection|
          self.current_connection = connection
          self.current_password = password
          yield(role)
        end
      end
    end
  end
  
  def sudo(command)
    "echo #{current_password} | sudo -S #{command}"
  end
  
  def expect(test, name=nil)
    method_name = name || parse_caller(caller[0]).last
    if test
      puts "#{method_name} - PASS"
      return true
    else
      puts "#{method_name} - FAIL"
      throw RuntimeError.new("Failed on: #{method_name}")
    end
  end
  
  def parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      file = Regexp.last_match[1]
      line = Regexp.last_match[2].to_i
      method = Regexp.last_match[3]
      [file, line, method]
    end
  end
  
  def configs_path(configs_path)
    boris.configs_path = configs_path
  end
end

module Commands
  def has_file?(path)
    !run_sudo("ls #{path}").include?("No such file or directory")
  end
  
  def apt_get_update
    expect(run_sudo("yes | apt-get update").include?('Done'))
  end
  
  def apt_get_install(command)
    expect(run_sudo("yes | apt-get install #{command}").include?('installed'))
  end
  
  def restart_apache
    expect(run_sudo("/etc/init.d/apache2 restart").include?('.done'))
  end
  
  def file_contents_equal(path, expected_content)
    run_sudo("cat #{path}") == expected_content
  end
  
  def backup_file(path)
    run_sudo "mv #{path} #{path}#{Time.now.to_i}"
  end
  
  def write_config(file, output_location, locals={})
    template = ERB.new open(boris.configs_path + "/#{file}.erb").read
    result = template.result build_binding(locals)
    lines = result.split("\n")
    unless has_file?(output_location) && file_contents_equal(output_location, result)
      backup_file(output_location) if has_file?(output_location)
      lines.each do |line|
        run "echo '#{line}' >> #{output_location}"
      end
    end
    # expect(file_contents_equal(output_location, result))
  end
  
  # BORROWED FROM: https://github.com/bmizerany/sinatra/commit/dc6e32a5cea29e9055463f6eff84f2b829a19c1c
  def build_binding(locals={})
    outer = binding
    locals_code = ""
    locals_hash = {}
    locals.each do |key, value|
      locals_code << "#{key} = locals_hash[:#{key}]\n"
      locals_hash[:"#{key}"] = value
    end
    Kernel.eval("#{locals_code}", outer)
    outer
  end
  
  def wrap_path(cmd)
    set_path + cmd
  end
  
  def run(cmd)
    if @directories && @directories.any?
      if cmd.match(';') # must be using sudo
        cmd.sub!(';', "; cd #{@directories.last}; ")
      else
        cmd = "cd #{@directories.last}; " + cmd
      end
    end
    puts "RUNNING CMD: #{wrap_path(cmd)}"
    result = ssh.exec! wrap_path(cmd)
    puts result
    result
  end
  
  def run_sudo(cmd)
    run sudo(cmd)
  end
  
  def in_directory(path)
    (@directories ||= []).push(path)
    yield
    @directories.pop
  end
end