# std includes
require 'pathname'
require 'set'

# gem includes
require 'rubygems'
require 'rufus-tokyo'

module Words
  
  class WordnetConnection
    
    def self.wordnet_connection
      @@wordnet_connection
    end
    
    def self.wordnet_connection=(x)
      @@wordnet_connection = x
    end
    
  end
  
  class Relation
    
    RELATION_TO_SYMBOL = { "-c" => :member_of_this_domain_topic, "+" => :derivationally_related_form, "%p" => :part_meronym, "~i" => :instance_hyponym, "@" => :hypernym, 
                    ";r" => :domain_of_synset_region, "!" => :antonym, "#p" => :part_holonym, "%s" => :substance_meronym, ";u" => :domain_of_synset_usage, 
                    "-r" => :member_of_this_domain_region, "#s" => :substance_holonym, "=" => :attribute, "-u" => :member_of_this_domain_usage, ";c" => :domain_of_synset_topic,
                    "%m"=> :member_meronym, "~" => :hyponym, "@i" => :instance_hypernym, "#m" => :member_holonym, "$" => :verb_group, ">" => :cause, "*" => :entailment,
                    "\\" => :pertainym, "<" => :participle_of_verb, "&" => :similar_to, "^" => :see_also }
    SYMBOL_TO_RELATION = RELATION_TO_SYMBOL.invert
    
    def initialize(relation_construct, source_synset)
      @symbol, @dest_synset_id, @pos, @source_dest = relation_construct.split('.')
      @dest_synset_id = @pos + @dest_synset_id
      @symbol = RELATION_TO_SYMBOL[@symbol]
      @source_synset = source_synset
    end
    
    def is_semantic?
      @source_dest == "0000"
    end
    
    def source_word
      is_semantic? ? @source_word = nil : @source_word = @source_synset.words[@source_dest[0..1].to_i(16)-1] unless defined? @source_word
      @source_word
    end
    
    def destination_word
      is_semantic? ? @destination_word = nil : @destination_word = destination.words[@source_dest[2..3].to_i(16)-1] unless defined? @destination_word
      @destination_word
    end
    
    def relation_type?(type)
      case 
        when SYMBOL_TO_RELATION.include?(type.to_sym)
        type.to_sym == @symbol
        when RELATION_TO_SYMBOL.include?(pos.to_s)
        POINTER_TO_SYMBOL[type.to_sym] == @symbol
      else
        false
      end
    end
    
    def relation_type
      @symbol
    end
    
    def destination
      @destination = Synset.new(@dest_synset_id) unless defined? @destination
      @destination
    end
    
    def to_s      
      @to_s = "#{relation_type.to_s.gsub('_', ' ').capitalize} relation between #{@source_synset.synset_id}'s word \"#{source_word}\" and #{@dest_synset_id}'s word \"#{destination_word}\"" if !is_semantic? && !defined?(@to_s) 
      @to_s = "Semantic #{relation_type.to_s.gsub('_', ' ')} relation between #{@source_synset.synset_id} and #{@dest_synset_id}" if  is_semantic? && !defined?(@to_s) 
      @to_s
    end
    
    def inspect
      { :symbol => @symbol, :dest_synset_id => @dest_synset_id, :pos => @pos, :source_dest => @source_dest }.inspect
    end
    
  end
  
  class Synset
    
    SYNSET_TYPE_TO_SYMBOL = {"n" => :noun, "v" => :verb, "a" => :adjective, "r" => :adverb, "s" => :adjective_satallite }
    
    def initialize(synset_id)
      @synset_hash = WordnetConnection::wordnet_connection[synset_id]
      # construct some conveniance menthods for relation type access
      Relation::SYMBOL_TO_RELATION.keys.each do |relation_type|
        self.class.send(:define_method, "#{relation_type}s?") do 
          relations(relation_type).size > 0
        end
        self.class.send(:define_method, "#{relation_type}s") do 
          relations(relation_type)
        end
      end
    end
    
    def synset_type
      SYNSET_TYPE_TO_SYMBOL[@synset_hash["synset_type"]]
    end
    
    def words
      @words = words_with_num.map { |word_with_num| word_with_num[:word] } unless defined? @words
      @words
    end
    
    def size
      words.size
    end
    
    def words_with_num
      @words_with_num = @synset_hash["words"].split('|').map { |word| word_parts = word.split('.'); { :word => word_parts[0].gsub('_', ' '), :num => word_parts[1] } } unless defined? @words_with_num
      @words_with_num
    end
    
    def synset_id
      @synset_hash["synset_id"]
    end
    
    def gloss
      @synset_hash["gloss"]
    end
    
    def inspect
      @synset_hash.inspect
    end
    
    def relations(type = :all)
      @relations = @synset_hash["relations"].split('|').map { |relation| Relation.new(relation, self) } unless defined? @relations
      case 
        when Relation::SYMBOL_TO_RELATION.include?(type.to_sym)
        @relations.select { |relation| relation.relation_type == type.to_sym }
        when Relation::RELATION_TO_SYMBOL.include?(type.to_s)
        @relations.select { |relation| relation.relation_type == Relation::RELATION_TO_SYMBOL[type.to_s] }
      else
        @relations
      end
    end
    
    def to_s
      @to_s = "#{synset_type.to_s.capitalize} including word(s): #{words.map { |word| '"' + word + '"' }.join(', ')} meaning: #{gloss}" unless defined? @to_s
      @to_s
    end
    
  end
  
  class Lemma
    
    POS_TO_SYMBOL = {"n" => :noun, "v" => :verb, "a" => :adjective, "r" => :adverb}
    SYMBOL_TO_POS = POS_TO_SYMBOL.invert
    
    def initialize(lemma_hash)
      @lemma_hash = lemma_hash
      # construct some conveniance menthods for relation type access
      SYMBOL_TO_POS.keys.each do |pos|
        self.class.send(:define_method, "#{pos}s?") do 
          synsets(pos).size > 0
        end
        self.class.send(:define_method, "#{pos}s") do 
          synsets(pos)
        end
      end
    end
    
    def lemma
      @lemma = @lemma_hash["lemma"].gsub('_', ' ') unless defined? @lemma
      @lemma
    end
    
    def available_pos
      @available_pos = synset_ids.map { |synset_id| POS_TO_SYMBOL[synset_id[0,1]] }.uniq unless defined? @available_pos
      @available_pos
    end
    
    def to_s
      @to_s = [lemma, " " + available_pos.join("/")].join(",") unless defined? @to_s
      @to_s
    end
    
    def synsets(pos = :all)
      relevent_synsets = case 
        when SYMBOL_TO_POS.include?(pos.to_sym)
        synset_ids.select { |synset_id| synset_id[0,1] == SYMBOL_TO_POS[pos.to_sym] }
        when POS_TO_SYMBOL.include?(pos.to_s)
        synset_ids.select { |synset_id| synset_id[0,1] == pos.to_s }
      else
        synset_ids
      end
      relevent_synsets.map { |synset_id| Synset.new synset_id }
    end
    
    def synset_ids
      @synset_ids = @lemma_hash["synset_ids"].split('|') unless defined? @synset_ids
      @synset_ids
    end
    
    def inspect
      @lemma_hash.inspect
    end
    
    alias word lemma
    
  end
  
  class Words
    
    def initialize(path = 'data/wordnet.tct')
      if (Pathname.new path).exist?
        WordnetConnection::wordnet_connection = Rufus::Tokyo::Table.new(path)
      else
        abort("Failed to locate the words database at #{(Pathname.new path).realpath}")
      end
    end
    
    def find(word)
      Lemma.new WordnetConnection::wordnet_connection[word]
    end
    
    def close
      WordnetConnection::wordnet_connection.close
    end
    
  end
  
end
