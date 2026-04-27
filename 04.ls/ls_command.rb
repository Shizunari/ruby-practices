#!/usr/bin/env ruby
# frozen_string_literal: true

# 出力列の最大値を指定する
COLMUN_UPPER_LIMIT = 3

def align_array(filenames, colmun)
  rows_count = filenames.length.ceildiv(colmun)
  align_sorted_array = filenames.each_slice(rows_count).to_a
  align_sorted_array[0].zip(*align_sorted_array[1..])
end

def to_matrix(filenames, max_length)
  filenames.each do |row_filenames|
    row_filenames.each_with_index do |filename, i|
      if i == row_filenames.length - 1
        print filename
      else
        print filename.to_s.ljust(max_length + 4)
      end
    end
    puts
  end
end

files_info = Dir.glob('*')
exit if files_info[0].nil?

max_filename_length = files_info.map(&:length).max
sorted_filenames = files_info.sort_by(&:downcase)
aligned_filenames = align_array(sorted_filenames, COLMUN_UPPER_LIMIT)
to_matrix(aligned_filenames, max_filename_length)
