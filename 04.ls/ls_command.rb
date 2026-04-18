#!/usr/bin/env ruby
# frozen_string_literal: true

def get_files(all: false)
  if all
    Dir.glob('*', File::FNM_DOTMATCH)
  else
    Dir.glob('*')
  end
end

def check_length(names)
  word_length = 0
  names.each do |name|
    word_length = name.size if name.size > word_length
  end
  word_length
end

def narabikae(names, colmun, rev: false)
  array_rows = (names.size.to_f / colmun).ceil
  sort_array = if rev
                 names.sort_by(&:downcase).reverse
               else
                 names.sort_by(&:downcase)
               end
  yoko_narabi = sort_array.each_slice(array_rows).to_a
  yoko_narabi[0].zip(*yoko_narabi[1..])
end

def output_names_only(names, length)
  names.each do |n|
    n.each do |name|
      print "#{name.to_s.ljust(length)}\t"
    end
    print "\n"
  end
end

# ファイル情報を取得
files_info = get_files
exit if files_info[0].nil?

# 文字列の長さチェック
max_word_len = check_length(files_info)

# 出力列を指定
output_colmun = 3

# 出力列に則って配列の並び替え
tate_narabi = narabikae(files_info, output_colmun)

# 長さ指定で配列を出力
output_names_only(tate_narabi, max_word_len)
