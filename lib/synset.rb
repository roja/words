require "relation.rb"
require "evocations.rb"

module Words

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

      @words ||= words_with_lexical_ids.map { |word_with_num| word_with_num[:word] }

      @words

    end

    def lexical_ids

      @words ||= words_with_lexical_ids.map { |word_with_num| word_with_num[:lexical_id] }

      @words

    end

    def size

      words.size

    end

    def words_with_lexical_ids

      @words_with_num ||= @synset_hash["words"].split('|').map { |word| word_parts = word.split('.'); { :word => word_parts[0].gsub('_', ' '), :lexical_id => word_parts[1] } }

      @words_with_num

    end

    def lexical_filenum

      @synset_hash["lexical_filenum"]

    end

    def lexical_catagory

      lexical[:lex]

    end

    def lexical_description

      lexical[:description]

    end

    def lexical

      NUM_TO_LEX[lexical_filenum.to_i]

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

      @relations ||= @synset_hash["relations"].split('|').map { |relation| Relation.new(relation, self, @wordnet_connection) }

      case
      when Relation::SYMBOL_TO_RELATION.include?(type.to_sym)
        @relations.select { |relation| relation.relation_type == type.to_sym }
      when Relation::RELATION_TO_SYMBOL.include?(type.to_s)
        @relations.select { |relation| relation.relation_type == Relation::RELATION_TO_SYMBOL[type.to_s] }
      else
        @relations
      end

    end

    def evocations
      
      evocations_arr = @wordnet_connection.evocations(synset_id)
      Evocations.new evocations_arr, self, @wordnet_connection unless evocations_arr.nil?

    end

    def to_s

      @to_s ||= "#{synset_type.to_s.capitalize} including word(s): #{words.map { |word| '"' + word + '"' }.join(', ')} meaning: #{gloss}"

      @to_s

    end

    alias word lemma

  end

end