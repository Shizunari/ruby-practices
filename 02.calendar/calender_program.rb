#!/usr/bin/env ruby

# ライブラリ読み込み
require 'optparse'
require 'date'

# 引数の設定と判定処理
input_options = {:m => Date.today.month.to_i, :y => Date.today.year.to_i }
OptionParser.new do |opt|
  opt.on('-m', '--month MONTH', '出力する月を数字で指定してください') do |month|
    unless (1..12).include?(month.to_i)
      abort 'Err: １〜１２の範囲で月数を指定してください。'
    end
    input_options[:m] = month.to_i
  end

  opt.on('-y', '--year YEAR', '出力する西暦を数字で指定してください') do |year|
    if year.to_i < 1970
      abort 'Err: 1970年以降の年数を指定してください。'
    end
    unless year.to_s.length == 4
      abort 'Err: 年数は4桁の西暦で入力してください。'
    end
    input_options[:y] = year.to_i
  end

  begin
    opt.parse!(ARGV)
  rescue
    # 引数を指定するが値を入力しなかった場合にエラーとなる為、エラー処理
    abort "Err: 引数を使用する場合は、値を設定してください。"
  end
end

# 変数に入力された月と年をセット
input_month = input_options[:m]
input_year = input_options[:y]

# 年・月・日・曜日をセット
WEEK_HEADER = '日 月 火 水 木 金 土'
month_start = Date.new(input_year, input_month, 1)
month_end = Date.new(input_year, input_month, -1)
calender_head = "#{input_month}月 #{input_year}年"

# 日付のスタート位置調整
days_word = '   ' * month_start.wday

# 日付の出力位置調整
(month_start..month_end).each do |date|
  days_word += "#{date.day}".rjust(2) + " "
  days_word += "\n" if date.saturday?
end

# 結果出力
puts calender_head.center(20)
puts WEEK_HEADER
puts days_word
