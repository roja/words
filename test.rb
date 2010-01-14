#!/usr/bin/env ruby

require 'lib/words'

if __FILE__ == $0
  
  wordnet = Words::Words.new
  
  puts wordnet.find('bat')
  puts wordnet.find('bat').available_pos.inspect
  puts wordnet.find('bat').lemma
  puts wordnet.find('bat').synsets('noun')
  puts wordnet.find('bat').synsets('noun').last.words.inspect
  puts wordnet.find('bat').synsets('noun').last.relations
  wordnet.find('bat').synsets('noun').last.relations.each { |relation| puts relation.inspect }
#  puts wordnet.find('bat').synsets('noun').last.methods
  puts wordnet.find('bat').synsets('noun').last.hyponyms?
  puts wordnet.find('bat').synsets('noun').last.participle_of_verbs?
  
#  puts wordnet.find('bat').synsets('noun').last.relations(:hyponym)
#  puts wordnet.find('bat').synsets('noun').last.relations("~")
#  puts wordnet.find('bat').synsets('verb').last.inspect
#  puts wordnet.find('bat').synsets('verb').last.words
#  puts wordnet.find('bat').synsets('verb').last.words_with_num.inspect
  
  wordnet.close
  
#    tokyo_index = Rufus::Tokyo::Table.new('data/wordnet.tct')
#        
#    puts tokyo_index['bat'].inspect
#    puts tokyo_index['n02139199'].inspect
#    
#    tokyo_index.close
  
#  index = PStore.new("data/index.pstore")
#  
#  index.transaction do  # begin transaction
#    puts index['hello'].inspect
#  end
  
end