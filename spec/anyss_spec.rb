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

  def out_file(file='sample.csv')
    File.join( @tmp_dir, file )
  end

  def in_file(ext)
    File.join( @data_dir, 'sample.%s'%ext )
  end

  def should_have_equal_content(file)
    stringify = lambda { |c| c.collect {|r| r } * " \n " }
    stringify[@csv].should == stringify[CSV.open(file,'r')]
  end

end

describe Anyss do

  it_should_behave_like "with temporary artifacts"

  describe ".to_cvs" do

    [ :xls, :ods, :gnumeric ].each do |ext|
      it "given ( data/sample.#{ext}, tmp/sample.csv ), should convert to tmp/sample.cvs" do
        @tmp_files << out_file
        Anyss.to_csv( in_file(ext), @tmp_files.last )
        should_have_equal_content(out_file)
      end
    end

    [ :xls, :ods, :gnumeric ].each do |ext|
      it "given ( data/sample.#{ext} ), should convert to data/sample.#{ext}.cvs" do
        Anyss.to_csv(in_file(ext))
        @tmp_files << in_file(ext)+'.csv'
        should_have_equal_content(@tmp_files.last)
      end
    end

    [ :txt, :jpg, :png, :gif, :doc ].each do |ext|
      it "given ( data/sample.#{ext} ), should raise Anyss::UnsupportedFileType" do
        lambda { Anyss.to_csv("file.#{ext}") }.should raise_error(Anyss::UnsupportedFileType)
      end
    end

  end
  
  [ :xls, :ods, :gnumeric, :csv ].each do |ext|
    it "given ( data/sample.#{ext}, &block ), should apply &block's stragtegy per row" do
      rows = []
      Anyss(in_file(ext)) { |row| rows << row.to_s }
      rows.should == @csv.collect { |r| r.to_s }
    end
  end

  [ :txt, :jpg, :png, :gif, :doc ].each do |ext|
    it "given ( data/sample.#{ext}, &block ), should raise Anyss::UnsupportedFileType" do
      lambda { Anyss("file.#{ext}"){} }.should raise_error(Anyss::UnsupportedFileType)
    end
  end

  it "given (*), should throw Anyss::MissingCodeBlock" do
    lambda { Anyss(any_args()) }.should raise_error(Anyss::MissingCodeBlock)
  end

end

# __END__
