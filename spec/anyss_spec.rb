require File.dirname(__FILE__) + '/spec_helper.rb'
require 'csv'

describe "with temporary artifacts", :shared => true do

  before(:each) do
    @spec_dir = File.dirname(File.expand_path(__FILE__))
    @data_dir = File.join( @spec_dir, 'data' )
    @tmp_dir = File.join( @spec_dir, 'tmp' )
    @tmp_files = []
    Dir.mkdir(@tmp_dir) unless File.exists?(@tmp_dir)
    @csv = CSV.open( File.join( @data_dir, 'sample.csv' ), 'r' )
  end
  
  after(:each) do
    @tmp_files.each { |f| File.delete(f) }
    Dir.delete(@tmp_dir)
    @csv.close
  end

  def out_path(file='sample.csv')
    File.join( @tmp_dir, file )
  end

  def in_path(ext)
    File.join( @data_dir, "sample.#{ext}" )
  end

  def should_have_equal_content(file)
    stringify = lambda { |c| c.collect {|r| r } * " \n " }
    stringify[@csv].should == stringify[CSV.open(file,'r')]
  end

end

describe "Anyss.to_csv" do

  it_should_behave_like "with temporary artifacts"

  def do_content_check( inputs, expected_out_file )
    ( out_file = Anyss.to_csv(*inputs) ).should == expected_out_file
    @tmp_files << out_file
    should_have_equal_content(out_file)
  end

  def do_error_check(inputs)
    lambda { 
      Anyss.to_csv(*inputs) 
      }.should raise_error(Anyss::UnsupportedFileType)
  end

  [ :xls, :ods, :gnumeric ].each do |ext|

    it "given ( data/sample.#{ext} ), should convert to data/sample.#{ext}.cvs" do
      do_content_check([ in_file=in_path(ext) ], "#{in_file}.csv" )
    end

    it "given ( data/sample.#{ext}, tmp/sample.csv ), should convert to tmp/sample.cvs" do
      do_content_check([ in_file=in_path(ext), out_path ], out_path )
    end

    it "given ( data/sample.#{ext}.file, :type => :#{ext} ), " +
       "should convert to data/sample.#{ext}.file.cvs" do
      do_content_check([ in_file=in_path("#{ext}.file"), { :type => ext } ], "#{in_file}.csv" )
    end

    it "given ( data/sample.#{ext}.file, tmp/sample.csv, :type => :#{ext} ), " +
       "should convert to tmp/sample.cvs" do
      do_content_check([ in_file=in_path("#{ext}.file"), out_path, { :type => ext } ], out_path )
    end

  end

  [ :txt, :jpg, :png, :gif, :doc ].each do |ext|

    it "given ( data/sample.#{ext} ), should raise Anyss::UnsupportedFileType" do
      do_error_check([ "file.#{ext}" ])
    end

    it "given ( data/sample.#{ext}, tmp/sample.csv ), should raise Anyss::UnsupportedFileType" do
      do_error_check([ "file.#{ext}", out_path ])
    end

    it "given ( data/sample.#{ext}, :type => :#{ext} ), should raise Anyss::UnsupportedFileType" do
      do_error_check([ "file.#{ext}", { :type => ext } ])
    end

    it "given ( data/sample.#{ext}, tmp/sample.csv, :type => :#{ext} ), " +
       "should raise Anyss::UnsupportedFileType" do
      do_error_check([ "file.#{ext}", out_path, { :type => ext } ])
    end

  end

end

describe Anyss do

  it_should_behave_like "with temporary artifacts"

  def do_strategy_check(inputs)
    rows = []
    Anyss(*inputs) { |row| rows << row.to_s }
    rows.should == @csv.collect { |r| r.to_s }
  end

  def do_reader_check(inputs)
    rows, reader = [], Anyss(*inputs)
    reader.each { |r| rows << r.to_s }
    reader.is_a?(Anyss::StringReader).should be_true
    rows.should == @csv.collect { |r| r.to_s }
    reader.close
  end
  
  def do_error_check( inputs, &block )
    lambda { 
      block_given? ? Anyss( *inputs, &block ) : Anyss(*inputs)
      }.should raise_error(Anyss::UnsupportedFileType)
  end

  [ :xls, :ods, :gnumeric, :csv ].each do |ext|

    it "given ( data/sample.#{ext}, &block ), should apply &block's stragtegy per row" do
      do_strategy_check([ in_path(ext) ])
    end

    it "given ( data/sample.#{ext}.file, :type => :#{ext}, &block ), " +
       "should apply &block's stragtegy per row" do
      do_strategy_check([ in_path("#{ext}.file"), { :type => ext } ])
    end

    it "given ( data/sample.#{ext} ), should return a CSV::StringReader" do
      do_reader_check([ in_path(ext) ])
    end

    it "given ( data/sample.#{ext}.file, :type => :#{ext} ), should return a Anyss::Reader" do
      do_reader_check([ in_path("#{ext}.file"), { :type => ext } ])
    end

  end

  [ :txt, :jpg, :png, :gif, :doc ].each do |ext|

    it "given ( data/sample.#{ext}, &block ), should raise Anyss::UnsupportedFileType" do
      do_error_check([ "file.#{ext}" ]) {}
    end

    it "given ( data/sample.#{ext}.file, :type => :#{ext}, &block ), " +
       "should raise Anyss::UnsupportedFileType" do
      do_error_check([ "file.#{ext}", { :type => ext } ]) {}
    end

    it "given ( data/sample.#{ext} ), should raise Anyss::UnsupportedFileType" do
      do_error_check([ "file.#{ext}" ])
    end

    it "given ( data/sample.#{ext}.file, :type => :#{ext} ), " +
       "should raise Anyss::UnsupportedFileType" do
      do_error_check([ "file.#{ext}", { :type => ext } ])
    end

  end

end

# __END__
