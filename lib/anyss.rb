$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'session'
require 'anyss/version'
require 'anyss/exceptions'

module Anyss

  class << self

    public

      ###
      # Generates a csv +out_file+ from +in_file+. If out_file is not specified, 
      # we use +in_file+ + '.csv' instead. 
      #
      # Examples:
      #
      #   in_file, out_file = 'fruits.ods', 'fruits.csv'
      #   Anyss.to_csv( in_file, out_file ) # creates 'fruits.csv'
      #   Anyss.to_csv( in_file )           # creates 'fruits.ods.csv'
      #
      # Currently, only *.xls, *.gnumeric & *.ods conversions are supported.
      #
      def to_csv( in_file, out_file=nil )
        out_file ||= "#{in_file}.csv"
        bash = Session::Bash.new
        bash.execute [ 'ssconvert', to_csv_opts(in_file), in_file, out_file ] * ' '
      end

    private

      def to_csv_opts(file)
        opts = [ 'export-type=Gnumeric_stf:stf_csv', 'recalc' ]
        opts << 'import-encoding=Gnumeric_' +
          case file[/\.(\w+)$/,1]
            when 'xls'
              'Excel:excel_dsf'
            when 'ods'
              'OpenCalc:openoffice'
            when 'gnumeric'
              'XmlIO:sax'
            else
              raise UnsupportedFileType
          end
        opts.collect { |o| "--#{o}" } * ' '
      end

  end

end

###
# Opens +in_file+, and applies &block's strategy to each row. Under the hood, 
# it converts +in_file+ to a temporary csv, and delegates core processing to 
# CSV::Reader.parse(fh).each(&block).
#
# Examples:
#
#   Anyss('locations.gnumeric') do |row|
#      # do some useful stuff for the row
#   end
#
# (see Anyss.to_csv for spreadsheet supported, with addition of *.csv)
#
def Anyss( in_file, &block )
  raise Anyss::MissingCodeBlock unless block_given?
  out_file = 
    if in_file !~ /\.csv$/
      Anyss.to_csv( in_file, out_file = in_file + ".#{Time.now.to_i}.csv" ) 
      out_file
    end
  File.open( out_file||in_file, 'r' ) { |fh| CSV::Reader.parse( fh, &block ) }
  File.unlink(out_file) if out_file
end
