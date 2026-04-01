1.upto(20) do |i|
  multipul_3 = i % 3
  multipul_5 = i % 5
  if multipul_3 == 0 && multipul_5 == 0
    puts "FizzBuzz"
  elsif multipul_3 == 0
    puts "Fizz"
  elsif multipul_5 == 0
    puts "Buzz"
  else
    puts i
  end
end