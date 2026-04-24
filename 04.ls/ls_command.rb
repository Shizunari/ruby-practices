#!/usr/bin/env ruby
# frozen_string_literal: true

def get_word_length(words)
  words.map(&:length).max
end

def alignment(words, colmun)
  array_rows = (words.length.to_f / colmun).ceil
  sort_array = words.sort_by(&:downcase)
  align_sort_array = sort_array.each_slice(array_rows).to_a
  align_sort_array[0].zip(*align_sort_array[1..])
end

def output_word_only(words, max_length)
  words.each do |row_words|
    row_words.each_with_index do |word, i|
      if i == row_words.length - 1
        print word
      else
        print word.to_s.ljust(max_length + 4)
      end
    end
    puts
  end
end

# 出力列の最大値を設定する
SET_OUTPUT_COLMUN = 3

files_info = Dir.glob('*')
exit if files_info[0].nil?

max_word_len = get_word_length(files_info)
align_files_info = alignment(files_info, SET_OUTPUT_COLMUN)
output_word_only(align_files_info, max_word_len)
