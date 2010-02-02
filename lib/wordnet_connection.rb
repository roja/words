# std includes
require 'pathname'

# gem includes
require 'rubygems'
require 'rufus-tokyo' if Gem.available?('rufus-tokyo')

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
          raise "Coulden't find the rufus-tokyo gem. Please ensure it's installed." unless Gem.available?('rufus-tokyo')
          @connection = Rufus::Tokyo::Table.new(@data_path.to_s, :mode => 'r')
          @connected = true
        elsif @connection_type == :pure
          # open the index is there
          File.open(@data_path, 'r') do |file|
            @connection = Marshal.load file.read
          end
          evocation_path = Pathname.new("#{File.dirname(__FILE__)}/../data/evocations.dmp")
          File.open(evocation_path, 'r') do |file|
            @evocations = Marshal.load file.read
          end if evocation_path.exist?
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
        raise "Failed to locate the words #{ @connection_type == :pure ? 'index' : 'dataset' } at #{@data_path}. Please insure you have created it using the words gems provided 'build_wordnet' command."
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
        { 'lemma' => raw_homographs[0], 'tagsense_counts' => raw_homographs[1], 'synset_ids' => raw_homographs[2]} unless raw_homographs.nil?
      else
        @connection[term]
      end
    end

    def evocations(senset_id)
      if connection_type == :pure
        if defined? @evocations
          raw_evocations = @evocations[senset_id + "s"]
          { 'relations' => raw_evocations[0], 'means' => raw_evocations[1], 'medians' => raw_evocations[2]} unless raw_evocations.nil?
        else
          nil
        end
      else
        @connection[senset_id + "s"]
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

end
