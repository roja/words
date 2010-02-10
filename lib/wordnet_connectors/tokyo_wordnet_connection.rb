# gem includes
require 'rubygems'
require 'rufus-tokyo' if Gem.available?('rufus-tokyo')

module Words

    # Provides a pure tokyo cabinate connector to the Wordnet dataset.
    class TokyoWordnetConnection

	## Returns the current connection status of the wordnet object.
	#
	# @return [true, false] The current connection status of the wordnet object.
	attr_reader :connected

	## Returns the current connection status of the wordnet object.
	#
	# @return [true, false] The current connection status of the wordnet object.
	alias :connected? connected

	# Returns the type of the current wordnet connection.
	#
	# @return [Symbol] The current wordnet connection type. Currently supported :pure & :tokyo.
	attr_reader :connection_type

	# Returns the datapath currently in use (this may be irrelevent when using the pure connector and thus could be nil.)
	#
	# @return [Pathname, nil] The path to the data directory currently in use. Returns nil if unknown.
	attr_reader :data_path

	# Returns the path to the wordnet collection currently in use (this may be irrelevent when using the tokyo connector and thus could be nil.)
	#
	# @return [Pathname, nil] The path to the wordnet collection currently in use. Returns nil if unknown.
	attr_reader :wordnet_path

	# Constructs a new tokyo ruby connector for use with the words wordnet class.
	#
	# @param [Pathname] data_path Specifies the directory within which constructed datasets can be found (tokyo index, evocations etc...)
	# @param [Pathname] wordnet_path Specifies the directory within which the wordnet dictionary can be found.
	# @return [PureWordnetConnection] A new wordnet connection.
	# @raise [BadWordnetConnector] If an invalid connector type is provided.
	def initialize(data_path, wordnet_path)

	    @data_path, @wordnet_path, @connection_type, @connected = data_path + 'wordnet.tct', wordnet_path, :tokyo, false

	    # ensure we have the rufus gem loaded, else there is little point in continuing...
	    raise BadWordnetConnector, "Coulden't find the rufus-tokyo gem. Please ensure it's installed." unless Gem.available?('rufus-tokyo')

	    open!

	end

	# Causes the connection specified within the wordnet object to be reopened if currently closed.
	# 
	# @raise [BadWordnetConnector] If an invalid connector type is provided.
	def open!

	    unless connected?
		if @data_path.exist?
		    @connection = Rufus::Tokyo::Table.new(@data_path.to_s, :mode => 'r')
		    @connected = true
		else
		    @connected = false
		    raise BadWordnetDataset, "Failed to locate the tokyo words dataset at #{@data_path}. Please insure you have created it using the words gems provided 'build_wordnet' command."
		end
	    end
	    return nil

	end

	# Causes the current connection to wordnet to be closed.
	#
	def close!

	    if connected?
		@connection.close
		@connected = false
	    end
	    return nil

	end

	# Locates from a term any relevent homographs and constructs a homographs hash.
	#
	# @param [String] term The specific term that is desired from within wordnet.
	# @result [Hash, nil] A hash in the format { 'lemma' => ..., 'tagsense_counts' => ..., 'synset_ids' => ...  }, or nil if no homographs are available.
	# @raise [NoWordnetConnection] If there is currently no wordnet connection.
	def homographs(term)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?
	    @connection[term]
	    
	end

	# Locates from a synset_id a specific synset and constructs a synset hash.
	#
	# @param [String] synset_id The synset id to locate.
	# @result [Hash, nil] A hash in the format { "synset_id" => ..., "lexical_filenum" => ..., "synset_type" => ..., "words" => ..., "relations" => ..., "gloss" => ... }, or nil if no synset is available.
	# @raise [NoWordnetConnection] If there is currently no wordnet connection.
	def synset(synset_id)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?
	    @connection[synset_id]

	end

	# Returns wheter evocations are currently avalable to use with the current wordnet object. (More information on setting these up can be found within the README)
	#
	# @return [true, false] Whether evocations are currently available or not.
	def evocations?

	    !evocations('n08112402').nil?

	end

	# Locates from a synset id any relevent evocations and constructs an evocations hash.
	#
	# @see Synset
	# @param [String] senset_id The id number of a specific synset.
	# @result [Hash, nil] A hash in the format { 'relations' => ..., 'means' => ..., 'medians' => ... }, or nil if no evocations are available.
	# @raise [NoWordnetConnection] If there is currently no wordnet connection.
	def evocations(synset_id)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?
	    @connection[synset_id + "s"]

	end

	# Provides a textural description of the current connection state of the Wordnet object.
	#
	# @return [String] A textural description of the current connection state of the Wordnet object. e.g. "Words not Connected" or "Words running in tokyo mode with dataset at /opt/wordnet"
	def to_s

	    "Words running in tokyo mode with dataset at #{@dataset_path}"

	end

    end

end