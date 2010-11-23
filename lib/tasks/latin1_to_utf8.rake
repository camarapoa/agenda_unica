require 'iconv'
#require 'facets/progressbar'
#require 'highline/import'
#require 'rchardet'

namespace :db do
  task :latin1_to_utf8 => :environment do    
    class Model < ActiveRecord::Base
      def self.inheritance_column
        nil
      end
    end
    
    tables = if ENV['tables']
      ENV['tables'].split
    else # Get all tables
      ActiveRecord::Base.connection.tables
    end.sort
    
    puts "The following tables were found:"
    puts tables
    exit unless agree("Continue? [y/n] ")

    latin1_to_utf8 = Iconv.new('UTF-8', 'LATIN1')
    
    tables.each do |table|
      Model.set_table_name(table)
      Model.reset_column_information
      attributes = Model.columns.map(&:name)
      records, count = Model.all, Model.count
      
      puts "TABLE #{table.upcase}"
      pbar = ProgressBar.new("Converting", count)

      begin
        Model.transaction do
          records.each do |record|
            attributes.each do |attribute|
              value = record.send(attribute)
              if value.is_a?(String) && CharDet.detect(value)['encoding'] == 'ISO-8859-1'
                record.send "#{attribute}=", latin1_to_utf8.iconv(value)
              end
            end
            record.save(false)
            pbar.inc
          end
        end
      rescue Exception => e
        puts "Could not complete conversion on table #{table}."
        puts e.message
        puts
      end
    end
  end
end

