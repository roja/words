 class Evocations

    def initialize(evocation_construct, source_synset, wordnet_connection)
      @wordnet_connection = wordnet_connection
      @source = source_synset
      @evocation_construct = evocation_construct
    end

    def means
      @means = @evocation_construct["means"].split('|') unless defined? @means
      @means
    end

    def medians
      @medians = @evocation_construct["medians"].split('|') unless defined? @medians
      @medians
    end

    def size
      means.size
    end

    def first
      self[0]
    end

    def last
      self[size-1]
    end

    def [] (index)
      { :destination => destinations[index], :mean => means[index], :median => medians[index] }
    end

    def destinations(pos = :all)
      destination_ids(pos).map { |synset_id| Synset.new synset_id, @wordnet_connection, @source.homographs }
    end

    def destination_ids(pos = :all)
      @destination_ids = @evocation_construct["relations"].split('|') unless defined? @destination_ids
      case
        when Homographs::SYMBOL_TO_POS.include?(pos.to_sym)
        @destination_ids.select { |synset_id| synset_id[0,1] == Homographs::SYMBOL_TO_POS[pos.to_sym] }
        when Homographs::POS_TO_SYMBOL.include?(pos.to_s)
        @destination_ids.select { |synset_id| synset_id[0,1] == pos.to_s }
      else
        @destination_ids
      end
    end

    def to_s
      "#{size} evocations from #{@source}"
    end

  end