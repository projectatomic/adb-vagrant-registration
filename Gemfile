source 'https://rubygems.org'

gemspec

group :development do
  gem 'vagrant',      git: 'https://github.com/mitchellh/vagrant.git'
  gem 'rake'
  gem 'cucumber', '~> 2.1'
  gem 'aruba', '~> 0.13'
  gem 'komenda', '~> 0.1.6'
  gem 'launchy'
  gem 'gem-compare'
  gem 'mechanize'
  gem 'vagrant-vbguest'
  gem 'vagrant-libvirt' if RUBY_PLATFORM =~ /linux/i
  gem 'fog-libvirt', '0.0.3' if RUBY_PLATFORM =~ /linux/i # https://github.com/pradels/vagrant-libvirt/issues/568
end

group :plugins do
  gem 'vagrant-registration', path: '.'
end
