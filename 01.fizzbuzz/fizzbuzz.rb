count = 0
result1 = 0
result2 = 0

while count < 20
  count += 1
  result1 = count.modulo(3)
  result2 = count.modulo(5)
  if result1 == 0 && result2 == 0
    puts "FizzBuzz"
  elsif result1 == 0
    puts "Fizz"
  elsif result2 == 0
    puts "Buzz"
  else
    puts count
  end
end

