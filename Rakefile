# coding: utf-8
require 'rubygems'
require 'rake'

begin
    require 'jeweler'
    Jeweler::Tasks.new do |gem|
	gem.name = "words"
	gem.summary = %Q{A Fast & Easy to use interface to WordNet® with cross ruby distribution compatibility.}
	gem.description = %Q{Words, with both pure ruby & tokyo-cabinate backends, implements a fast interface to Wordnet® over the same easy-to-use API. The FFI backend makes use of Tokyo Cabinet and the FFI interface, rufus-tokyo, to provide cross ruby distribution compatability and blistering speed. The pure ruby interface operates on a special ruby optimised index along with the basic dictionary files provided by WordNet®. I have attempted to provide ease of use in the form of a simple yet powerful api and installation is a sintch!}
	gem.email = "roja@arbia.co.uk"
	gem.homepage = "http://github.com/roja/words"
	gem.authors = ["Roja Buck"]
	gem.executables = [ "build_wordnet" ]
	gem.default_executable = "build_wordnet"
	gem.rubyforge_project = 'words'
	gem.add_development_dependency "rspec", ">= 2.11.0"
    end
    Jeweler::GemcutterTasks.new
rescue LoadError
    puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
end

begin
    require 'rcov'
    RSpec::Core::RakeTask.new(:rcov) do |spec|
	spec.libs << 'lib' << 'spec'
	spec.pattern = 'spec/**/*_spec.rb'
	spec.rcov = true
    end
rescue LoadError
    task :rcov do
	abort "RCov is not available. In order to run rcov, you must: sudo gem install rcov"
    end
end

task :spec => :check_dependencies

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
    version = File.exist?('VERSION') ? File.read('VERSION') : ""

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "test #{version}"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
end