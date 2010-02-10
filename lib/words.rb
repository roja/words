# Standard library includes
require 'pathname'

# Local includes
require File.join(File.dirname(__FILE__),'homographs.rb')

# The Words gem namespace. Within this we offer a number of classes to facilitate useful interaction with words and language. Currently this largly consists of Words::Wordnet which offers simple wordnet access.
module Words

    # We identify each wordnet connector installed and there paths
    SUPPORTED_CONNECTIORS = Dir[File.join(File.dirname(__FILE__),'wordnet_connectors','*_wordnet_connection.rb')].inject(Hash.new) { |connectors, connection_file| connectors[ File.basename(connection_file).split('_').first.to_sym ] = connection_file; connectors }
    # An array of tippical wordnet install locations (if you have a standard install somewhere else please open as an issue in github so we can improve!)
    DEFAULT_WORDNET_LOCATIONS = ['/usr/share/wordnet', '/usr/local/share/wordnet', '/usr/local/WordNet-3.0', '/opt/WordNet-3.0', '/opt/wordnet', '/opt/local/share/WordNet-3.0/']

    # Exception to indicate that the wordnet connector specified is not currently available/supported.
    class BadWordnetConnector < RuntimeError; end
    # Exception to indicate that there is a problem connecting to a specified wordnet dataset.
    class BadWordnetDataset < RuntimeError; end
    # Exception to indicate that there is not currently a connection to wordnet and thus any request cannot be fulfilled.
    class NoWordnetConnection < RuntimeError; end

    # The wordnet class provides a control come interface for interaction with the wordnet dataset of your choice. It creates a connection, based on specified paramaters, to a wordnet dataset and provides
    # the means to interigate that dataset. In addition it provides control and information about that wordnet connection.
    class Wordnet

	## Returns the underlying wordnet connection object.
	#
	# @return [PureWordnetConnection, TokyoWordnetConnection] the underlying wordnet connection object.
	attr_reader :wordnet_connection

	# Constructs a new wordnet connection object.
	#
	# @param [Symbol] connector_type Specifies the connector type or mode desired. Current supported connectors are :pure and :tokyo.
	# @param [String, Symbol] wordnet_path Specifies the directory within which the wordnet dictionary can be found. It can be set to :search to attempt to locate wordnet automatically.
	# @param [String, Symbol] data_path Specifies the directory within which constructed datasets can be found (tokyo index, evocations etc...) It can be set to :default to use the standard location inside the gem directory.
	# @return [Wordnet] The wordnet connection object.
	# @raise [BadWordnetConnector] If an invalid connector type is provided.
	def initialize(connector_type = :pure, wordnet_path = :search, data_path = :default)

	    # Check and specify useful paths
	    wordnet_path = Wordnet::locate_wordnet(wordnet_path)
	    data_path = (data_path == :default ? Pathname.new(File.join(File.dirname(__FILE__), '..', 'data')) : Pathname.new( data_path ))

	    # Ensure we have a valid connector type
	    raise BadWordnetConnector, "You specified an unsupported wordnet connector type. Supported connectors are: #{SUPPORTED_CONNECTIORS}" unless SUPPORTED_CONNECTIORS.include? connector_type

	    # Assuming we have a valid connection type we can import the relevant code (the reason we do this dynamically is to reduce loadtime)
	    require SUPPORTED_CONNECTIORS[connector_type]
	     
	    # Construct the connector object
	    @wordnet_connection = Words.const_get( File.basename(SUPPORTED_CONNECTIORS[connector_type], '.rb').gsub(/(^|_)(.)/) { $2.upcase } ).new(data_path, wordnet_path)
	    
	end

	# Locates the set of homographs within wordnet specific to the term entered.
	#
	# @param [String] term The specific term that is desired from within wordnet. This is caps insensative & we do a small amount of cleanup.
	# @return [Homographs] An object encaptulating the homographs of the desired term. If the term cannot be located within wordnet then nil is returned.
	# @raise [NoWordnetConnection] If there is currently no wordnet connection.
	def find(term)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?
	    homographs = @wordnet_connection.homographs(term)
	    Homographs.new(homographs, @wordnet_connection) unless homographs.nil?

	end

	# Returns the type of the current wordnet connection.
	#
	# @return [Symbol] The current wordnet connection type. Currently supported :pure & :tokyo.
	def connection_type

	    @wordnet_connection.connection_type if defined? @wordnet_connection

	end

	# Returns the path to the wordnet collection currently in use (this may be irrelevent when using the tokyo connector and thus could be nil.)
	#
	# @return [Pathname, nil] The path to the wordnet collection currently in use. Returns nil if unknown.
	def wordnet_path

	    @wordnet_connection.wordnet_path if defined? @wordnet_connection

	end

	# Returns the datapath currently in use (this may be irrelevent when using the pure connector and thus could be nil.)
	#
	# @return [Pathname, nil] The path to the data directory currently in use. Returns nil if unknown.
	def data_path

	    @wordnet_connection.data_path if defined? @wordnet_connection

	end

	# Causes the current connection to wordnet to be closed.
	#
	def close!

	    @wordnet_connection.close! if defined? @wordnet_connection

	end

	# Causes the connection specified within the wordnet object to be reopened if currently closed.
	#
	def open!

	    @wordnet_connection.open! if defined? @wordnet_connection

	end

	## Returns the current connection status of the wordnet object.
	#
	# @return [true, false] The current connection status of the wordnet object.
	def connected?

	    @wordnet_connection.connected? if defined? @wordnet_connection

	end

	## Returns wheter evocations are currently avalable to use with the current wordnet object. (More information on setting these up can be found within the README)
	#
	# @return [true, false] Whether evocations are currently available or not.
	def evocations?

	    @wordnet_connection.evocations? if defined? @wordnet_connection

	end

	# Provides a textural description of the current connection state of the Wordnet object.
	#
	# @return [String] A textural description of the current connection state of the Wordnet object. e.g. "Words not Connected" or "Words running in pure mode using wordnet files found at /opt/wordnet"
	def to_s

	    # Return a description of the connector
	    !connected? ? "Words not connected" : @wordnet_connection.to_s

	end

	private

	# Attempts to locates wordnet given an array of directories to look within
	#
	# @param [String, Array<String>, Symbol] base_dirs Either a path, array of or the :search symbol. Will attempt to locate wordnet within these specified directories.
	# @return [Pathname, nil] The pathname of the wordnet dictionary files or nil if they can't be located within the passed directorie(s)
	def self.locate_wordnet(base_dirs)

	    base_dirs = case base_dirs
	    when :search
		DEFAULT_WORDNET_LOCATIONS
	    else
		[ base_dirs ].flatten
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