#!/usr/bin/env ruby

#require 'rubygems'
#require 'words'
require 'lib/words.rb'

if __FILE__ == $0
  
    wordnet = Words::Wordnet.new :tokyo

    puts wordnet.connected? 
    wordnet.close!
    puts wordnet.connected?
    wordnet.open!
    puts wordnet.connected?
  
    puts wordnet

    puts wordnet.find('squash racquet')

    puts wordnet.find('bat')
    puts wordnet.find('bat').available_pos.inspect
    puts wordnet.find('bat').lemma
    puts wordnet.find('bat').nouns?
    puts wordnet.find('bat').synsets('noun')
    puts wordnet.find('bat').noun_ids
    puts wordnet.find('bat').synsets(:noun)[2].words.inspect
    puts wordnet.find('bat').nouns.last.relations
    wordnet.find('bat').synsets('noun').last.relations.each { |relation| puts relation.inspect }
    puts wordnet.find('bat').synsets('noun').last.hyponyms?
    puts wordnet.find('bat').synsets('noun').last.participle_of_verbs?
  
    puts wordnet.find('bat').synsets('noun').last.relations(:hyponym)
    puts wordnet.find('bat').synsets('noun').last.hyponyms?
    puts wordnet.find('bat').synsets('noun').last.relations("~")
    puts wordnet.find('bat').synsets('verb').last.inspect
    puts wordnet.find('bat').synsets('verb').last.words.inspect
    puts wordnet.find('bat').synsets('verb').last.words_with_lexical_ids.inspect
  
    puts wordnet.find('bat').synsets('verb').first.lexical.inspect
    puts wordnet.find('bat').synsets('verb').first.lexical_description
  
    puts wordnet.find('jkashdfajkshfksjdhf')

    if wordnet.evocations?
	puts wordnet.find("broadcast").senses.first.evocations
	puts wordnet.find("broadcast").senses.first.evocations.means
	puts wordnet.find("broadcast").senses.first.evocations[1].inspect
	puts wordnet.find("broadcast").senses.first.evocations[20][:destination].words
    end

    wordnet.close!
  
end