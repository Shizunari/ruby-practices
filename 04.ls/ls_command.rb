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

def make_line_infomation(path, filename)
  file_type = File.ftype("#{path}/#{filename}").slice(0, 1)
  if file_type == 'l'
    link_type_information(path, filename, file_type)
  else
    other_type_information(path, filename, file_type)
  end
end

def link_type_information(path, filename, file_type)
  link_file_detail = []
  link_file_detail << { type: file_type }
  select_fileclass = File.lstat("#{path}/#{filename}")
  link_file_detail.concat(type_infomation_common_part(select_fileclass))
  link_file_detail << { date_time: select_fileclass.mtime.strftime('%b %_d %R') }
  link_file_detail << { name: "#{File.basename("#{path}/#{filename}")} -> #{File.readlink("#{path}/#{filename}")}" }
  array_to_hash = {}
  array_to_hash.merge(*link_file_detail)
end

def other_type_information(path, filename, file_type)
  file_detail = []
  file_detail << if file_type == 'f'
                   { type: '-' }
                 else
                   { type: file_type }
                 end
  select_fileclass = File.stat("#{path}/#{filename}")
  file_detail.concat(type_infomation_common_part(select_fileclass))
  file_detail << { date_time: File.mtime("#{path}/#{filename}").strftime('%b %_d %R') }
  file_detail << { name: File.basename("#{path}/#{filename}") }
  array_to_hash = {}
  array_to_hash.merge(*file_detail)
end

def type_infomation_common_part(file_class)
  common_detail = []
  common_detail << { permission: number_to_rwx(file_class.mode.to_s(8).slice(-3, 3)) }
  common_detail << { hardlink: file_class.nlink }
  common_detail << { owner: Etc.getpwuid(file_class.uid).name }
  common_detail << { group: Etc.getgrgid(file_class.gid).name }
  common_detail << { data_size: file_class.size }
  common_detail << { block_size: file_class.blocks }
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
  display_array = []
  (reversed_filenames || files_info).each do |filename|
    display_array << make_line_infomation(directory_path, filename)
  end

  puts "total #{display_array.sum { |h| h[:block_size] }}"
  display_line(display_array)
end
