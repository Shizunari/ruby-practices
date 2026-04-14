#!/usr/bin/env ruby

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a

point_of_frames = []
0.upto(9) do |frame|
  # ストライクの処理
  if frames[frame][0] == 10
    # 次フレームもストライクか判定
    if frames[frame + 1][0] == 10
      point_of_frames << 20 + frames[frame + 2][0]
    else
      point_of_frames << 10 + frames[frame + 1].sum
    end
  # スペアの処理
  elsif frames[frame].sum == 10
    point_of_frames << 10 + frames[frame + 1][0]
  # 9ピン以下
  else
    point_of_frames << frames[frame].sum
  end
end
puts "スコア：#{point_of_frames.sum}"
