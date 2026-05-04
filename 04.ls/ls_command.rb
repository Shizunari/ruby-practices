#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# 出力列の最大値を指定する
COLMUN_UPPER_LIMIT = 3

def search_directory(path, all:)
  if all
    Dir.entries(path).sort
  else
    Dir.glob('*')
  end
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
        double_byte_adjustment = diff_single_doublebyte(filename)
        print filename.to_s.ljust(max_length + 4 - double_byte_adjustment)
      end
    end
    puts
  end
end

def diff_single_doublebyte(str)
  return 0 if str.nil?

  display_length = str.each_char.map { |c| c.bytesize > 1 ? 2 : 1 }.sum
  display_length - str.length
end

begin
  options = ARGV.getopts('a')
rescue OptionParser::ParseError => e
  warn "Error: #{e.class}"
  abort '-a以外の引数は利用できません。'
end

directory_path = Dir.pwd
files_info = search_directory(directory_path, all: options['a'])
exit if files_info[0].nil?

max_filename_length = files_info.map(&:length).max
matrixed_filenames = array_to_matrix(files_info, COLMUN_UPPER_LIMIT)
display_matrix(matrixed_filenames, max_filename_length)
