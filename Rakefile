require "bundler"
Bundler.setup

gemspec = eval(File.read("linalg.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["linalg.gemspec"] do
  system "gem build linalg.gemspec"
  system "gem install linalg-#{Linalg::VERSION}.gem"
end
