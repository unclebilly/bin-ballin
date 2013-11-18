#!/usr/bin/env ruby
require 'exiv2'
require 'pp'
require 'date'
require 'fileutils'
require 'pry'

dir = ARGV[0]
unless dest = ARGV[1]
 raise "usage: #{$0} src_dir dest_dir"
end
dest = File.expand_path(dest)
verbose = !ENV["VERBOSE"].nil?

results = {}

Dir[File.join(dir, '*')].each do |file|
  file = File.expand_path(file)
  begin
    m = Exiv2::ImageFactory.open(file)
    m.read_metadata
  rescue Exiv2::BasicError => e
    puts "skipping #{file}"
    next
  end
  if m.exif_data["Exif.Photo.DateTimeOriginal"].nil?
    puts "No date information for #{file}, skipping"
    next
  end
  date, time = m.exif_data["Exif.Photo.DateTimeOriginal"].split(/\s/)
  date.gsub!(/:/,'/')
  combined = date + ' ' + time
  date=DateTime.parse(combined)
  results[file] = date
end

results.each do |file, date|
  unless date.is_a? Date
    binding.pry
  end
  new_path = File.expand_path(File.join(dest, date.year.to_s, Date::MONTHNAMES[date.month]), __FILE__)

  FileUtils.mkdir_p(new_path, :verbose => verbose)
  FileUtils.cp(file, new_path, :verbose => verbose)
end