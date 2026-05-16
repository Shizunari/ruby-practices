#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

# マトリックス時の出力列の最大値を指定
COLMUN_UPPER_LIMIT = 3

PERMISSION_SYMBOLS = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

def search_directory(path, all:)
  if all
    Dir.entries(path).sort
  else
    Dir.glob('*')
  end
end

def reverse_order?(options)
  options['r'] || false
end

def array_to_matrix(filenames, colmun)
  rows_count = filenames.length.ceildiv(colmun)
  slice_filenames_array = filenames.each_slice(rows_count).to_a
  slice_filenames_array[0].zip(*slice_filenames_array[1..])
end

def display_matrix(filenames, max_length)
  filenames.each do |row_filenames|
    row_filenames.each_with_index do |filename, i|
      if i == row_filenames.length - 1
        print filename
      else
        display_position_adjustment = diff_full_half_width(filename)
        print filename.to_s.ljust(max_length + 4 - display_position_adjustment)
      end
    end
    puts
  end
end

def diff_full_half_width(str)
  return 0 if str.nil?

  display_length = str.each_char.map { |c| c.bytesize > 1 ? 2 : 1 }.sum
  display_length - str.length
end

def display_line(informations)
  hardlink_length = informations.map { |h| h[:hardlink] }.max.to_s.length
  owner_length = informations.map { |h| h[:owner] }.max.to_s.length
  group_length = informations.map { |h| h[:group] }.max.to_s.length
  datasize_length = informations.map { |h| h[:data_size] }.max.to_s.length

  informations.each do |information|
    print information[:type]
    print information[:permission]
    print " #{information[:hardlink].to_s.rjust(hardlink_length)}"
    print " #{information[:owner].to_s.ljust(owner_length)}"
    print "  #{information[:group].to_s.ljust(group_length)}"
    print "  #{information[:data_size].to_s.rjust(datasize_length)}"
    print " #{information[:date_time]}"
    puts " #{information[:name]}"
  end
end

def number_to_rwx(permission_numbers)
  return_symbol = ''
  permission_numbers.chars.each do |n|
    return_symbol += PERMISSION_SYMBOLS[n]
  end
  return_symbol
end

def file_detailed_information(path, filename)
  file_path = File.join(path, filename)
  file_stat = File.lstat(file_path)
  file_type = File.ftype(file_path).slice(0, 1)
  type_pattern = if file_type == 'f'
                   '-'
                 else
                   file_type
                 end
  name_pattern = if file_type == 'l'
                   "#{File.basename(file_path)} -> #{File.readlink(file_path)}"
                 else
                   File.basename(file_path)
                 end
  build_display_file_detail(file_path, file_stat, type_pattern, name_pattern)
end

def build_display_file_detail(file_path, file_stat, type_pattern, name_pattern)
  {
    type: type_pattern,
    permission: number_to_rwx(file_stat.mode.to_s(8).slice(-3, 3)),
    hardlink: file_stat.nlink,
    owner: Etc.getpwuid(file_stat.uid).name,
    group: Etc.getgrgid(file_stat.gid).name,
    data_size: file_stat.size,
    date_time: File.mtime(file_path).strftime('%b %_d %R'),
    name: name_pattern,
    block_size: file_stat.blocks
  }
end

begin
  options = ARGV.getopts('alr')
rescue OptionParser::ParseError => e
  warn "Error: #{e.class}"
  abort '-a, -l, -r 以外の引数は利用できません。'
end

directory_path = Dir.pwd
files_info = search_directory(directory_path, all: options['a'])
if files_info[0].nil?
  puts 'total 0' if options['l']
  exit
end

reversed_filenames = files_info.reverse if reverse_order?(options)

if !options['l']
  max_filename_length = files_info.map(&:length).max
  matrixed_filenames = array_to_matrix(reversed_filenames || files_info, COLMUN_UPPER_LIMIT)
  display_matrix(matrixed_filenames, max_filename_length)

else
  display_array = (reversed_filenames || files_info).map { |item| file_detailed_information(directory_path, item) }
  puts "total #{display_array.sum { |h| h[:block_size] }}"
  display_line(display_array)
end
