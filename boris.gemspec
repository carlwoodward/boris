lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |gem|
  gem.name = "boris"
  gem.version = "0.0.1"
  gem.platform = Gem::Platform::RUBY
  gem.authors = ["Carl Woodward"]
  gem.email = "carl@carlwoodward.com"
  gem.homepage = "http://github.com/cjwoodward/boris"
  gem.summary = "Super simple server provising/management"
  gem.description = "Really easy server management"
  gem.has_rdoc = false
  gem.files = %w(Readme.md Rakefile) + Dir.glob("{lib}/**/*")
  gem.require_path = "lib"
  gem.executables = [ 'boris' ]
end