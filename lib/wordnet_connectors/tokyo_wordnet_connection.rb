# gem includes
require 'rubygems'
require 'rufus-tokyo' if Gem.available?('rufus-tokyo')

module Words

    class TokyoWordnetConnection

	attr_reader :connected, :connection_type, :data_path, :wordnet_path

	def initialize(data_path, wordnet_path)

	    @data_path, @wordnet_path, @connection_type, @connected = data_path, wordnet_path, :tokyo, false

	    # ensure we have the rufus gem loaded, else there is little point in continuing...
	    raise BadWordnetConnector, "Coulden't find the rufus-tokyo gem. Please ensure it's installed." unless Gem.available?('rufus-tokyo')

	    open!

	end

	def open!

	    @dataset_path = @data_path + 'wordnet.tct'
	    if @dataset_path.exist?
		@connection = Rufus::Tokyo::Table.new(@dataset_path.to_s, :mode => 'r')
		@connected = true
	    else
		@connected = false
		raise BadWordnetDataset, "Failed to locate the tokyo words dataset at #{@dataset_path}. Please insure you have created it using the words gems provided 'build_wordnet' command."
	    end

	end

	def close!

	    if connected?
		@connection.close
		@connected = false
	    end

	end

	# main methods for connector 

	def homographs(term)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?
	    @connection[term]
	    
	end
	
	def synset(synset_id)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?
	    @connection[synset_id]

	end

	def evocations?

	    !evocations('v00973074').nil?

	end

	def evocations(senset_id)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?
	    @connection[senset_id + "s"]

	end

	def to_s

	    "Words running in tokyo mode with dataset at #{@dataset_path}"

	end

	alias connected? connected

    end

end