# Words - A fast, easy to use interface to WordNet® with cross ruby distribution compatability. #

## About ##

Words implements a fast interface to [Wordnet®](http://wordnet.princeton.edu) which makes use of [Tokyo Cabinet](http://1978th.net/tokyocabinet/) and a FFI interface, [rufus-tokyo](http://github.com/jmettraux/rufus-tokyo), to provide cross ruby distribution compatability and blistering speed. I have attempted to provide ease of use in the form of a simple yet powerful api and installation is a sintch, we even include the data in it's tokyo data format (subject to the original wordnet licencing.)

## Installation ##

First ensure you have [Tokyo Cabinet](http://1978th.net/tokyocabinet/) installed. It should be nice and easy...

After this it should be just a gem to install. For those of you with old rubygems versions first:

    gem install gemcutter  # These two steps are only necessary if you haven't
    gem tumble             # yet installed the gemcutter tools
    
Otherwise and after it's simply:

	gem install words
	
Then your ready to rock and roll. :)

## Build Data (Optional) ##

If you want to build the wordnet dataset file yourself, from the original wordnet files, you can use the bundled "build_dataset.rb"

	./build_dataset.rb -h #this will give you the usage
	sudo ./build_dataset.rb #this will attempt to build the data locating the original wordnet files through a search...

## Usage ##

Heres a few little examples of using words within your programs.


    require 'rubygems'
    require 'words'
    
    data = Words::Words.new
    
    # locate a word
    lemma = data.find("bat")
    
    lemma.to_s # => bat, noun/verb
    lemma.available_pos.inspect # => [:noun, :verb]
    
    lemma.synsets(:noun) # => array of synsets which represent nouns of the lemma bat
    # or
    lemma.nouns # => array of synsets which represent nouns of the lemma bat
    lemma.verbs? #=> true
    
    # specify a sense
    sense = lemma.nouns.last
    sense2 = lemma.nouns[2]
    
    sense.gloss # => a club used for hitting a ball in various games
    sense2.words # => ["cricket bat", "bat"]
    sense.relations.first # => "Semantic hypernym relation between n02806379 and n03053474"

    sense.relations(:hyponym) # => Array of hyponyms associated with the sense
    # or
    sense.hyponyms # => Array of hyponyms associated with the sense
    sense.hyponyms? # => true
    
    sense.relations.first.is_semantic? # => true
    sense.relations.first.source_word # => nil
    sense.relations.first.destination # => the synset of n03053474
    
    sense.derivationally_related_forms.first.is_semantic? # => false
    sense.derivationally_related_forms.first.source_word # => "bat"
    sense.derivationally_related_forms.first.destination_word # => "bat"
    sense.derivationally_related_forms.first.destination # => the synset of v01413191
        

## Note on Patches/Pull Requests ##
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright ##

Copyright (c) 2010 Roja Buck. See LICENSE for details.
