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
Week_str = '日 月 火 水 木 金 土'
month_start = Date.new(input_year, input_month, 1)
month_end = Date.new(input_year, input_month, -1)
calender_head = "#{input_month}月 #{input_year}年"

# 日付のスタート位置調整
days_str = '   ' * month_start.wday

# 日付の出力位置調整
(month_start.day..month_end.day).each do |date|
  if (1..9).include?(date)
    days_str += " #{date}".ljust(3)
  else
    days_str += "#{date}".ljust(3)
  end
  check_saturday = Date.parse("#{input_year}-#{input_month}-#{date}")
  days_str = days_str + "\n" if check_saturday.saturday?
end

# 結果出力
puts calender_head.center(20)
puts Week_str
puts days_str
