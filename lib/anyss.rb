$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'session'
require 'anyss/version'
require 'anyss/exceptions'
require 'anyss/reader'
require 'anyss/string_reader'

module Anyss

  class << self

    SUPPORTED_TYPES = {
      :xls      => 'encoding=Gnumeric_Excel:excel_dsf',
      :ods      => 'type=Gnumeric_OpenCalc:openoffice',
      :gnumeric => 'encoding=Gnumeric_XmlIO:sax'
      }

    public

      ###
      # Generates a csv +out_file+ from +in_file+. If +out_file+ is not specified, 
      # we use "#{in_file}.csv" instead. Returns name of +out_file+.
      #
      # The extension of +in_file+ is used for guessing the appropriate encoding 
      # to use, which may not aways work, eg. weird file naming. opts[:type] may 
      # be used to override this guessing. 
      #
      # Example 1 (+in_file+ with sensible extension):
      #
      #   in_file, out_file = 'fruits.ods', 'fruits.csv'
      #   Anyss.to_csv( in_file, out_file ) # creates & returns 'fruits.csv'
      #   Anyss.to_csv( in_file )           # creates & returns 'fruits.ods.csv'
      #
      # Example 2 (overriding +in_file+ insensible extension):
      #
      #   in_file, out_file = 'fruits.foo', 'fruits.csv'
      #   Anyss.to_csv( in_file, out_file, :type => :ods ) # creates & returns 'fruits.csv'
      #   Anyss.to_csv( in_file, :type => :ods )           # creates & returns 'fruits.foo.csv'
      #
      # Currently, only the followings are supported:
      # * +in_file+ of *.xls, *.gnumeric and *.ods
      # * opts[:type] of :gnumeric, :ods and :xls
      #
      def to_csv( in_file, out_file=nil, opts={} )
        if out_file.is_a?(Hash)
          opts, out_file = {}.merge(out_file), nil
        end
        out_file ||= "#{in_file}.csv"
        execute( csv_opts( in_file, opts[:type] ), in_file, out_file )
        out_file
      end

    private

      def execute(*args)
        Session::Bash.new.execute( [ 'ssconvert', args ].flatten.join(' ') )
      end

      def csv_opts( file, type )
        [ 'recalc', 'export-type=Gnumeric_stf:stf_csv', 
          'import-%s' % derive_type( type, file )
          ].collect { |o| "--#{o}" } * ' '
      end

      def derive_type( type, file=nil )
        if type
          SUPPORTED_TYPES[type.to_sym] or raise UnsupportedFileType 
        else
          derive_type(file[/\.(\w+)$/,1])
        end
      end

  end

end

###
# Opens +in_file+, and:
# * applies &block's strategy to each row if &block is specified, otherwise
# * returns an instance of Anyss::StringReader
#
# Example 1 (+in_file+ with sensible extension):
#
#   Anyss( 'locations.gnumeric' ) { |row| ... } # do useful stuff for each row
#   Anyss( 'locations.gnumeric' )               # returns Anyss::Reader instance
#
# Example 2 (overriding +in_file+ insensible extension):
#
#   Anyss( 'locations.foo', :type => :gnumeric ) { |row| ... } 
#   Anyss( 'locations.foo', :type => :gnumeric )
#
# (see Anyss.to_csv for +opts+ and spreadsheets supported, with addition of *.csv)
#
def Anyss( in_file, opts={}, &block )
  tmp_file = ( in_file =~ /\.csv$/ || opts[:type] == :csv ) ? 
    nil : Anyss.to_csv( in_file, "#{in_file}.#{Time.now.to_i}.csv", opts )
  out = block_given? ?
    File.open( tmp_file||in_file, 'r' ) { |fh| Anyss::Reader.parse( fh, &block ) } :
    Anyss::StringReader.new(Anyss::Reader.parse(IO.readlines(tmp_file||in_file)*""))
  File.unlink(tmp_file) if tmp_file
  out
end
