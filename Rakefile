require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "words"
    gem.summary = %Q{A Fast & Easy to use interface to WordNet® with cross ruby distribution compatability.}
    gem.description = %Q{Words, with both pure ruby & tokyo-cabinate backends, implements a fast interface to Wordnet® over the same easy-to-use API. The FFI backend makes use of Tokyo Cabinet and the FFI interface, rufus-tokyo, to provide cross ruby distribution compatability and blistering speed. The pure ruby interface operates on a special ruby optimised index along with the basic dictionary files provided by WordNet®. I have attempted to provide ease of use in the form of a simple yet powerful api and installation is a sintch!}
    gem.email = "roja@arbia.co.uk"
    gem.homepage = "http://github.com/roja/words"
    gem.authors = ["Roja Buck"]
    gem.add_dependency "trollop", ">= 1.15"
    gem.add_dependency 'rufus-tokyo', '>= 1.0.5'
    gem.executables = [ "build_wordnet" ]
    gem.default_executable = "build_wordnet"
    gem.rubyforge_project = 'words'
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "words #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
