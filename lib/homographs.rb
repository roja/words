require "synset.rb"

module Words

  class Homographs

    POS_TO_SYMBOL = {"n" => :noun, "v" => :verb, "a" => :adjective, "r" => :adverb}
    SYMBOL_TO_POS = POS_TO_SYMBOL.invert

    def initialize(raw_homographs, wordnet_connection)

      @wordnet_connection = wordnet_connection
      @raw_homographs = raw_homographs

      # construct some conveniance menthods for relation type access
      SYMBOL_TO_POS.keys.each do |pos|
        self.class.send(:define_method, "#{pos}s?") do
          size(pos) > 0
        end
        self.class.send(:define_method, "#{pos}s") do
          synsets(pos)
        end
        self.class.send(:define_method, "#{pos}_count") do
          size(pos)
        end
        self.class.send(:define_method, "#{pos}_ids") do
          synset_ids(pos)
        end
      end
      
    end

    def tagsense_counts

      @tagsense_counts ||= @raw_homographs["tagsense_counts"].split('|').map { |count| { POS_TO_SYMBOL[count[0,1]] => count[1..-1].to_i }  }

      @tagsense_counts

    end

    def lemma

      @lemma ||= @raw_homographs["lemma"].gsub('_', ' ')

      @lemma

    end

    def available_pos

      @available_pos ||= synset_ids.map { |synset_id| POS_TO_SYMBOL[synset_id[0,1]] }.uniq

      @available_pos

    end

    def to_s

      @to_s ||= [lemma, " " + available_pos.join("/")].join(",")

      @to_s

    end

    def size(pos = :all)

      synset_ids(pos).size

    end

    def synsets(pos = :all)

      synset_ids(pos).map { |synset_id| Synset.new synset_id, @wordnet_connection, self }

    end

    def synset_ids(pos = :all)

      @synset_ids ||= @raw_homographs["synset_ids"].split('|')

      case
      when SYMBOL_TO_POS.include?(pos.to_sym)
        @synset_ids.select { |synset_id| synset_id[0,1] == SYMBOL_TO_POS[pos.to_sym] }
      when POS_TO_SYMBOL.include?(pos.to_s)
        @synset_ids.select { |synset_id| synset_id[0,1] == pos.to_s }
      else
        @synset_ids
      end

    end

    def inspect

      @raw_homographs.inspect

    end

    alias word lemma
    alias pos available_pos
    alias senses synsets
    alias sense_ids synset_ids

  end

end