#!/usr/bin/env ruby

# ライブラリ読み込み
require 'optparse'
require 'date'

# 引数の設定と判定処理
params = {}
OptionParser.new do |opt|
  opt.on('-m', '--month MONTH', '出力する月を数字で指定してください') do |month|
    unless 0 < month.to_i && month.to_i < 13
      puts '１〜１２の範囲で月を指定してください。'
      exit
    end
    params[:m] = month.to_i
  end

  opt.on('-y', '--year YEAR', '出力する西暦を数字で指定してください') do |year|
    if year.to_i < 1970
      puts '1970年以降の年数を指定してください。'
      exit
    end
    unless year.to_s.length == 4
      puts '年数は西暦で入力してください。'
      exit
    end
    params[:y] = year.to_i
  end

  opt.parse!(ARGV)
end

# 引数を設定しなかった時の処理（暫定）
input_year = params[:y]
input_year = Date.today.year.to_i if input_year.nil?

input_month = params[:m]
input_month = Date.today.month.to_i if input_month.nil?

# 年・月・日・曜日をセット
Week_str = '日 月 火 水 木 金 土'
month_start = Date.new(input_year, input_month, 1)
month_end = Date.new(input_year, input_month, -1) # これでもいいらしい
calender_head = input_month.to_s + '月 ' + input_year.to_s + '年'
start_point = month_start.cwday
days_str = ''

# カレンダーの出力値作成
# 日付のスタート位置調整
unless start_point == 7
  start_point.times do
    days_str += '   '
  end
end
# 日付の出力位置調整
ii = 0
while month_end.day > ii
  ii += 1
  days_str = if ii < 10
               days_str + ' ' + ii.to_s
             else
               days_str + ii.to_s
             end
  xx = Date.parse(input_year.to_s + '-' + input_month.to_s + '-' + ii.to_s)
  days_str = if xx.saturday?
               days_str + "\n"
             else
               days_str + ' '
             end
end

# 結果出力
puts calender_head.center(20)
puts Week_str
puts days_str
