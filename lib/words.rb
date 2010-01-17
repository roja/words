# std includes
require 'pathname'
require 'set'

# gem includes
require 'rubygems'
require 'rufus-tokyo'

module Words
  
  class WordnetConnection
    
    SHORT_TO_POS_FILE_TYPE = { 'a' => 'adj', 'r' => 'adv', 'n' => 'noun', 'v' => 'verb' }
    
    attr_reader :connected, :connection_type, :data_path, :wordnet_dir
    
    def initialize(type, path, wordnet_path)
      @data_path = Pathname.new("#{File.dirname(__FILE__)}/../data/wordnet.tct") if type == :tokyo && path == :default
      @data_path = Pathname.new("#{File.dirname(__FILE__)}/../data/index.dmp") if type == :pure && path == :default
      @connection_type = type
      
      if @data_path.exist?
        if @connection_type == :tokyo
          @connection = Rufus::Tokyo::Table.new(@data_path.to_s, :mode => 'r')
          @connected = true
        elsif @connection_type == :pure
          # open the index is there
          File.open(@data_path,'r') do |file|
            @connection = Marshal.load file.read
          end
          # search for the wordnet files
          if locate_wordnet?(wordnet_path)
            @connected = true
          else
            @connected = false
            raise "Failed to locate the wordnet database. Please ensure it is installed and that if it resides at a custom path that path is given as an argument when constructing the Words object."
          end
        else
          @connected = false
        end
      else
        @connected = false
        raise "Failed to locate the words #{ @connection_type == :pure ? 'index' : 'dataset' } at #{@data_path}. Please insure you have created it using the words gems provided 'build_dataset.rb' command."
      end
      
    end
    
    def close
      @connected = false
      if @connected && connection_type == :tokyo
        connection.close 
      end
      return true
    end
    
    def homographs(term)
      if connection_type == :pure
        raw_homographs = @connection[term]
        { 'lemma' => raw_homographs[0], 'tagsense_counts' => raw_homographs[1], 'synset_ids' => raw_homographs[2]}
      else
        @connection[term]
      end
    end
    
    def synset(synset_id)
      if connection_type == :pure
        pos = synset_id[0,1]      
        File.open(@wordnet_dir + "data.#{SHORT_TO_POS_FILE_TYPE[pos]}","r") do |file|
          file.seek(synset_id[1..-1].to_i)
          data_line, gloss = file.readline.strip.split(" | ")
          data_parts = data_line.split(" ")        
          synset_id, lexical_filenum, synset_type, word_count = pos + data_parts.shift, data_parts.shift, data_parts.shift, data_parts.shift.to_i(16)
          words = Array.new(word_count).map { "#{data_parts.shift}.#{data_parts.shift}" }
          relations = Array.new(data_parts.shift.to_i).map { "#{data_parts.shift}.#{data_parts.shift}.#{data_parts.shift}.#{data_parts.shift}" }
          { "synset_id" => synset_id, "lexical_filenum" => lexical_filenum, "synset_type" => synset_type, "words" => words.join('|'), "relations" => relations.join('|'), "gloss" => gloss.strip }          
        end
      else
        @connection[synset_id]
      end
    end
    
    def locate_wordnet?(base_dirs)
      
      base_dirs = case base_dirs
        when :search
        ['/usr/share/wordnet', '/usr/local/share/wordnet', '/usr/local/WordNet-3.0']
      else
        [ base_dirs ] 
      end
      
      base_dirs.each do |dir|
        ["", "dict"].each do |sub_folder| 
          path = Pathname.new(dir + sub_folder)
          @wordnet_dir = path if (path + "data.noun").exist?
          break if !@wordnet_dir.nil?
        end
      end
      
      return !@wordnet_dir.nil?
      
    end
    
  end
  
  class Relation
    
    RELATION_TO_SYMBOL = { "-c" => :member_of_this_domain_topic, "+" => :derivationally_related_form, "%p" => :part_meronym, "~i" => :instance_hyponym, "@" => :hypernym, 
                    ";r" => :domain_of_synset_region, "!" => :antonym, "#p" => :part_holonym, "%s" => :substance_meronym, ";u" => :domain_of_synset_usage, 
                    "-r" => :member_of_this_domain_region, "#s" => :substance_holonym, "=" => :attribute, "-u" => :member_of_this_domain_usage, ";c" => :domain_of_synset_topic,
                    "%m"=> :member_meronym, "~" => :hyponym, "@i" => :instance_hypernym, "#m" => :member_holonym, "$" => :verb_group, ">" => :cause, "*" => :entailment,
                    "\\" => :pertainym, "<" => :participle_of_verb, "&" => :similar_to, "^" => :see_also }
    SYMBOL_TO_RELATION = RELATION_TO_SYMBOL.invert
    
    def initialize(relation_construct, source_synset, wordnet_connection)
      @wordnet_connection = wordnet_connection
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
      @destination = Synset.new @dest_synset_id, @wordnet_connection unless defined? @destination
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
    SYNSET_TYPE_TO_NUMBER = { "n" => 1, "v" => 2, "a" => 3, "r" => 4, "s" => 5 }
    NUM_TO_LEX = [ { :lex => :adj_all, :description => "all adjective clusters" },
    { :lex => :adj_pert, :description => "relational adjectives (pertainyms)" },
    { :lex => :adv_all, :description => "all adverbs" },
    { :lex => :noun_Tops, :description => "unique beginner for nouns" },
    { :lex => :noun_act, :description => "nouns denoting acts or actions" },
    { :lex => :noun_animal, :description => "nouns denoting animals" },
    { :lex => :noun_artifact, :description => "nouns denoting man-made objects" },
    { :lex => :noun_attribute, :description => "nouns denoting attributes of people and objects" },
    { :lex => :noun_body, :description => "nouns denoting body parts" },
    { :lex => :noun_cognition, :description => "nouns denoting cognitive processes and contents" },
    { :lex => :noun_communication, :description => "nouns denoting communicative processes and contents" },
    { :lex => :noun_event, :description => "nouns denoting natural events" },
    { :lex => :noun_feeling, :description => "nouns denoting feelings and emotions" },
    { :lex => :noun_food, :description => "nouns denoting foods and drinks" },
    { :lex => :noun_group, :description => "nouns denoting groupings of people or objects" },
    { :lex => :noun_location, :description => "nouns denoting spatial position" },
    { :lex => :noun_motive, :description => "nouns denoting goals" },
    { :lex => :noun_object, :description => "nouns denoting natural objects (not man-made)" },
    { :lex => :noun_person, :description => "nouns denoting people" },
    { :lex => :noun_phenomenon, :description => "nouns denoting natural phenomena" },
    { :lex => :noun_plant, :description => "nouns denoting plants" },
    { :lex => :noun_possession, :description => "nouns denoting possession and transfer of possession" },
    { :lex => :noun_process, :description => "nouns denoting natural processes" },
    { :lex => :noun_quantity, :description => "nouns denoting quantities and units of measure" },
    { :lex => :noun_relation, :description => "nouns denoting relations between people or things or ideas" },
    { :lex => :noun_shape, :description => "nouns denoting two and three dimensional shapes" },
    { :lex => :noun_state, :description => "nouns denoting stable states of affairs" },
    { :lex => :noun_substance, :description => "nouns denoting substances" },
    { :lex => :noun_time, :description => "nouns denoting time and temporal relations" },
    { :lex => :verb_body, :description => "verbs of grooming, dressing and bodily care" },
    { :lex => :verb_change, :description => "verbs of size, temperature change, intensifying, etc." },
    { :lex => :verb_cognition, :description => "verbs of thinking, judging, analyzing, doubting" },
    { :lex => :verb_communication, :description => "verbs of telling, asking, ordering, singing" },
    { :lex => :verb_competition, :description => "verbs of fighting, athletic activities" },
    { :lex => :verb_consumption, :description => "verbs of eating and drinking" },
    { :lex => :verb_contact, :description => "verbs of touching, hitting, tying, digging" },
    { :lex => :verb_creation, :description => "verbs of sewing, baking, painting, performing" },
    { :lex => :verb_emotion, :description => "verbs of feeling" },
    { :lex => :verb_motion, :description => "verbs of walking, flying, swimming" },
    { :lex => :verb_perception, :description => "verbs of seeing, hearing, feeling" },
    { :lex => :verb_possession, :description => "verbs of buying, selling, owning" },
    { :lex => :verb_social, :description => "verbs of political and social activities and events" },
    { :lex => :verb_stative, :description => "verbs of being, having, spatial relations" },
    { :lex => :verb_weather, :description => "verbs of raining, snowing, thawing, thundering" },
    { :lex => :adj_ppl, :description => "participial adjectives" } ]
    
    def initialize(synset_id, wordnet_connection, homographs)
      @wordnet_connection = wordnet_connection
      @synset_hash = wordnet_connection.synset(synset_id)
      @homographs = homographs
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
    
    def lexical_ids
      @words = words_with_num.map { |word_with_num| word_with_num[:lexical_id] } unless defined? @words
      @words
    end
    
    def size
      words.size
    end
    
    def words_with_lex_ids
      @words_with_num = @synset_hash["words"].split('|').map { |word| word_parts = word.split('.'); { :word => word_parts[0].gsub('_', ' '), :lexical_id => word_parts[1] } } unless defined? @words_with_num
      @words_with_num
    end
    
    def lexical_filenum
      @synset_hash["lexical_filenum"].to_i
    end
    
    def lexical_catagory
      lexical[:lex]
    end
    
    def lexical_description
      lexical[:description]
    end
    
    def lexical
      NUM_TO_LEX[@synset_hash["lexical_filenum"].to_i]
    end
    
    def synset_id
      @synset_hash["synset_id"]
    end
    
    def gloss
      @synset_hash["gloss"]
    end
    
    def lemma
      @homographs.lemma
    end
    
    def homographs
      @homographs
    end
    
    def inspect
      @synset_hash.inspect
    end
    
    def relations(type = :all)
      @relations = @synset_hash["relations"].split('|').map { |relation| Relation.new(relation, self, @wordnet_connection) } unless defined? @relations
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
  
  class Homographs
    
    POS_TO_SYMBOL = {"n" => :noun, "v" => :verb, "a" => :adjective, "r" => :adverb}
    SYMBOL_TO_POS = POS_TO_SYMBOL.invert
    
    def initialize(raw_homographs, wordnet_connection)
      @wordnet_connection = wordnet_connection
      @lemma_hash = raw_homographs
      # construct some conveniance menthods for relation type access
      SYMBOL_TO_POS.keys.each do |pos|
        self.class.send(:define_method, "#{pos}s?") do 
          synsets(pos).size > 0
        end
        self.class.send(:define_method, "#{pos}s") do 
          synsets(pos)
        end
        self.class.send(:define_method, "#{pos}_ids") do 
          synset_ids(pos)
        end
      end
    end
    
    def tagsense_counts
      @tagsense_counts = @raw_homographs["tagsense_counts"].split('|').map { |count| { POS_TO_SYMBOL[count[0,1]] => count[1..-1].to_i }  } unless defined? @tagsense_counts
      @tagsense_counts
    end
    
    def lemma
      @lemma = @raw_homographs["lemma"].gsub('_', ' ') unless defined? @lemma
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
      synset_ids(pos).map { |synset_id| Synset.new synset_id, self, @wordnet_connection }
    end
    
    def synset_ids(pos = :all)
      @synset_ids = @raw_homographs["synset_ids"].split('|') unless defined? @synset_ids
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
  
  class Words
    
    @wordnet_connection = nil
    
    def initialize(type = :tokyo, path = :default, wordnet_path = :search)
      @wordnet_connection = WordnetConnection.new(type, path, wordnet_path)
    end
    
    def find(word)
      Homographs.new  @wordnet_connection.homographs(word), @wordnet_connection
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
    
    def to_s
      return "Words not connected" if !connected
      return "Words running in pure mode using wordnet files found at #{wordnet_dir} and index at #{@wordnet_connection.data_path}" if connection_type == :pure
      return "Words running in tokyo mode with dataset at #{@wordnet_connection.data_path}" if connection_type == :tokyo
    end
    
  end
  
end
