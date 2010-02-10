# std library includes
require 'pathname'

# local includes
require File.join(File.dirname(__FILE__),'homographs.rb')

module Words

    # we identify each wordnet connector installed and there paths
    SUPPORTED_CONNECTIORS = Dir[File.join(File.dirname(__FILE__),'wordnet_connectors','*_wordnet_connection.rb')].inject(Hash.new) { |connectors, connection_file| connectors[ File.basename(connection_file).split('_').first.to_sym ] = connection_file; connectors }
    DEFAULT_WORDNET_LOCATIONS = ['/usr/share/wordnet', '/usr/local/share/wordnet', '/usr/local/WordNet-3.0', '/opt/WordNet-3.0', '/opt/wordnet', '/opt/local/share/WordNet-3.0/']

    # specify some useful exception types
    class BadWordnetConnector < RuntimeError; end
    class BadWordnetDataset < RuntimeError; end
    class NoWordnetConnection < RuntimeError; end

    # specify the wordnet control object
    class Wordnet

	attr_reader :wordnet_connection
    
	def initialize(connector_type = :pure, data_path = :default, wordnet_path = :search)

	    # check and specify useful paths
	    wordnet_path = Wordnet::locate_wordnet(wordnet_path)
	    data_path = (data_path == :default ? Pathname.new(File.join(File.dirname(__FILE__), '..', 'data')) : Pathname.new( data_path ))

	    # ensure we have a valid connector type
	    raise BadWordnetConnector, "You specified an unsupported wordnet connector type. Supported connectors are: #{SUPPORTED_CONNECTIORS}" unless SUPPORTED_CONNECTIORS.include? connector_type

	    # assuming we have a valid connection type we can import the relevant code (the reason we do this dynamically is to reduce loadtime)
	    require SUPPORTED_CONNECTIORS[connector_type]
	     
	    # construct the connector object
	    @wordnet_connection = Words.const_get( File.basename(SUPPORTED_CONNECTIORS[connector_type], '.rb').gsub(/(^|_)(.)/) { $2.upcase } ).new(data_path, wordnet_path)
	    
	    # construct some conveniance menthods for relation type access
	    [:connection_type, :wordnet_path, :data_path, :close!, :open!, :connected?, :evocations?].each do |method_name|
		self.class.send(:define_method, method_name) do
		    @wordnet_connection.send method_name if defined? @wordnet_connection
		end
	    end

	end

	def find(term)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?
	    homographs = @wordnet_connection.homographs(term)
	    Homographs.new(homographs, @wordnet_connection) unless homographs.nil?

	end
	
	def to_s

	    # return a description of the connector
	    !connected? ? "Words not connected" : @wordnet_connection.to_s

	end

	private

	def self.locate_wordnet(base_dirs)

	    base_dirs = case base_dirs
	    when :search
		DEFAULT_WORDNET_LOCATIONS
	    else
		[ base_dirs ]
	    end

	    base_dirs.each do |dir|
		["", "dict"].each do |sub_folder|
		    path = Pathname.new(dir + sub_folder)
		    return path if (path + "data.noun").exist?
		end
	    end

	    return nil

	end

    end
  
end