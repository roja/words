# local includes
require File.join(File.dirname(__FILE__), 'synset.rb')

module Words

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

	    return nil if is_semantic?
	    @source_word ||= @source_synset.words[@source_dest[0..1].to_i(16)-1]

	end

	def destination_word

	    return nil if is_semantic?
	    @destination_word ||= destination.words[@source_dest[2..3].to_i(16)-1]

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

	    @destination ||= Synset.new(@dest_synset_id, @wordnet_connection, nil)

	end

	def to_s

	    if is_semantic?
		@to_s ||= "Semantic #{relation_type.to_s.gsub('_', ' ')} relation between #{@source_synset.synset_id} and #{@dest_synset_id}"
	    else
		@to_s ||= "#{relation_type.to_s.gsub('_', ' ').capitalize} relation between #{@source_synset.synset_id}'s word \"#{source_word}\" and #{@dest_synset_id}'s word \"#{destination_word}\""
	    end

	end

	def inspect

	    { :symbol => @symbol, :dest_synset_id => @dest_synset_id, :pos => @pos, :source_dest => @source_dest }.inspect
      
	end

    end

end