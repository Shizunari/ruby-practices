#!/usr/bin/env ruby
# frozen_string_literal: true

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

def strike?(frame)
  frame[0] == 10
end

def spare?(frame)
  !strike?(frame) && frame.sum == 10
end

score = 0.upto(9).sum do |n|
  next_frame = frames[n + 1]
  if strike?(frames[n])
    if strike?(next_frame)
      20 + frames[n + 2][0]
    else
      10 + next_frame.sum
    end
  elsif spare?(frames[n])
    10 + next_frame[0]
  else
    frames[n].sum
  end
end
puts "スコア：#{score}"
