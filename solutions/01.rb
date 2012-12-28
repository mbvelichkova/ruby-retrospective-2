class Integer
  def prime?(number)
    (2...number).each do |current|
        if number % current == 0
         return false
       end
     end
     true
  end

  def prime_divisors
    divisors = []
    (2..self.abs).each do |element|
        divisors << element if self.abs % element == 0
    end

    prime_divisors = []
     divisors.each do |element|
        prime_divisors << element if prime?(element)
    end

      prime_divisors
   end
end

class Range
  def fizzbuzz
    result = []
    self.each do |element|
      if element % 3 == 0 && element % 5 == 0
        result << :fizzbuzz
      elsif element % 3 == 0
        result << :fizz
      elsif element % 5 == 0
        result << :buzz
      else
        result << element
      end
    end
  result
  end
end

class Hash
  def group_values
    result = Hash.new { |hash, key| hash[key] = [] }
    self.each { |key, value| result[value].push key }

    result
  end
end

class Array
  def densities
    result = self.collect { |element| self.count(element) }
  end
end