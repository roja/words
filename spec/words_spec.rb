$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'words'

describe "Words Constructer" do

    it "should reject bad modes" do
	lambda { Words::Wordnet.new(:rubbish) }.should raise_exception(Words::BadWordnetConnector)
    end

    it "should when in pure mode, when provided with a bad wordnet directory, return a BadWordnetDataset exception" do
	lambda { Words::Wordnet.new(:pure, '/lib') }.should raise_exception(Words::BadWordnetDataset)
    end

    it "should when in tokyo mode, when provided with a bad dataset directory, return a BadWordnetDataset exception" do
	lambda { Words::Wordnet.new(:tokyo, :search, '/lib') }.should raise_exception(Words::BadWordnetDataset)
    end

end

describe "Pure Words Constructor" do

    #    should when in pure mode, , return

    before do
	@words = Words::Wordnet.new(:pure)
    end

    after do
	@words.close!
    end

    it "should accept pure mode" do
	@words.should_not be_nil
    end

    it "should when given the request for a pure mode return a pure connection" do
	@words.wordnet_connection.should be_kind_of Words::PureWordnetConnection
    end

    it "should when given the request for a pure mode return an open pure connection" do
	@words.connected?.should be_true
    end
    
    it "should when in pure mode, report itself as to in to_s" do
	@words.to_s.should match /Words running in pure mode using wordnet files found at .*/
    end

    it "should when in pure mode, when the connection is closed, report itself as closed" do
	@words.close!
	@words.connected?.should be_false
    end

    it "should when in pure mode, when the connection is closed, report itself as closed in to_s" do
	@words.close!
	@words.to_s.should match 'Words not connected'
    end

    it "should when in pure mode, when the connection is closed and then re-opened, report itself as open" do
	@words.close!
	@words.open!
	@words.connected?.should be_true
    end

    it "should when in pure mode, when the connection is closed, raise NoWordnetConnection exception if a find is attempted" do
	@words.close!
	lambda { @words.find('test') }.should raise_exception(Words::NoWordnetConnection)
    end

    it "should when checked report itself as a pure connection" do
	@words.connection_type.should equal :pure
    end

    it "should when in pure mode, when given a term within wordnet, return a valid response" do
	@words.find("mouse").should_not be_nil
    end

    it "should when in pure mode, when given a term not in wordnet, return nil" do
	@words.find("lksdhflasdf;lkjdsfkljsdlkfjsadlkf").should be_nil
    end

    it "should when in pure mode, (assuming evocations are installed on the test environment) return true when asked if evocations are available, return nil" do
	@words.evocations?.should be_true
    end

end

describe "Tokyo Words Constructor" do

    before do
	@words = Words::Wordnet.new(:tokyo)
    end

    after do
	@words.close!
    end

    it "should accept tokyo mode" do
	@words.should_not be_nil
    end

    it "should when given the request for a tokyo mode return a tokyo connection" do
	@words.wordnet_connection.should be_kind_of Words::TokyoWordnetConnection
    end

    it "should when given the request for a tokyo mode return an open tokyo connection" do
	@words.connected?.should be_true
    end

    it "should when in tokyo mode should report itself as to in to_s" do
	@words.to_s.should match /Words running in tokyo mode with dataset at .*/
    end

    it "should when in tokyo mode should when the connection is closed report itself as closed" do
	@words.close!
	@words.connected?.should be_false
    end

    it "should when in tokyo mode should when the connection is closed report itself as closed in to_s" do
	@words.close!
	@words.to_s.should match 'Words not connected'
    end

    it "should when in tokyo mode, when the connection is closed and then re-opened, report itself as open" do
	@words.close!
	@words.open!
	@words.connected?.should be_true
    end

    it "should when in tokyo mode, when the connection is closed, raise NoWordnetConnection exception if a find is attempted" do
	@words.close!
	lambda { @words.find('test') }.should raise_exception(Words::NoWordnetConnection)
    end

    it "should when checked report itself as a tokyo connection" do
	@words.connection_type.should equal :tokyo
    end

    it "should when in tokyo mode, when given a term within wordnet, return a valid response" do
	@words.find("mouse").should_not be_nil
    end

    it "should when in tokyo mode, when given a term not in wordnet, return nil" do
	@words.find("lksdhflasdf;lkjdsfkljsdlkfjsadlkf").should be_nil
    end

    it "should when in tokyo mode, (assuming evocations are installed on the test environment) return true when asked if evocations are available, return nil" do
	@words.evocations?.should be_true
    end
    
end

