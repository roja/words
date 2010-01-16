#!/usr/bin/env ruby

require 'rubygems'
require 'words'

if __FILE__ == $0
  
  wordnet = Words::Words.new  :pure
  
  puts wordnet
  
  puts wordnet.find('bat')
  puts wordnet.find('bat').available_pos.inspect
  puts wordnet.find('bat').lemma
  puts wordnet.find('bat').nouns?
  puts wordnet.find('bat').synsets('noun')
  puts wordnet.find('bat').noun_ids
  puts wordnet.find('bat').synsets(:noun).last.words.inspect
  puts wordnet.find('bat').nouns.last.relations
  wordnet.find('bat').synsets('noun').last.relations.each { |relation| puts relation.inspect }
  puts wordnet.find('bat').synsets('noun').last.hyponyms?
  puts wordnet.find('bat').synsets('noun').last.participle_of_verbs?
  
  puts wordnet.find('bat').synsets('noun').last.relations(:hyponym)
  puts wordnet.find('bat').synsets('noun').last.hyponyms?
  puts wordnet.find('bat').synsets('noun').last.relations("~")
  puts wordnet.find('bat').synsets('verb').last.inspect
  puts wordnet.find('bat').synsets('verb').last.words
  puts wordnet.find('bat').synsets('verb').last.words_with_num.inspect
  
  puts wordnet.find('bat').synsets('verb').first.lexical.inspect
  puts wordnet.find('bat').synsets('verb').first.lexical_description
  
  wordnet.close
  
end