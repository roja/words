require "homographs.rb"
require "wordnet_connection.rb"

module Words
  
  class Words
    
    @wordnet_connection = nil
    
    def initialize(type = :pure, path = :default, wordnet_path = :search)

      @wordnet_connection = WordnetConnection.new(type, path, wordnet_path)

    end
    
    def find(word)

      homographs = @wordnet_connection.homographs(word)
      Homographs.new  homographs, @wordnet_connection unless homographs.nil?

    end
    
    def connection_type

      @wordnet_connection.connection_type

    end
    
    def wordnet_dir

      @wordnet_connection.wordnet_dir

    end
    
    def close

      @wordnet_connection.close

    end
    
    def connected

      @wordnet_connection.connected

    end

    def evocations_enabled?

      @wordnet_connection.evocations_enabled?
      
    end
    
    def to_s

      return "Words not connected" if !connected
      return "Words running in pure mode using wordnet files found at #{wordnet_dir} and index at #{@wordnet_connection.data_path}" if connection_type == :pure
      return "Words running in tokyo mode with dataset at #{@wordnet_connection.data_path}" if connection_type == :tokyo
      
    end
    
  end
  
end
