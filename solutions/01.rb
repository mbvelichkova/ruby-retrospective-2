class Integer
  def prime?
    2.upto(abs-1).none? { |divisor| remainder(divisor).zero? }
  end

  def prime_divisors
    2.upto(abs).select { |element| remainder(element).zero? and element.prime? }
  end
end

class Range
  def fizzbuzz
    collect do |element|
      if    element % 15 == 0 then :fizzbuzz
      elsif element % 3 == 0  then :fizz
      elsif element % 5 == 0  then :buzz
      else
                                   element
      end
    end
  end
end

class Hash
  def group_values
    each_with_object({}) do |(key, value), result|
      result[value] ||= []
      result[value] << key
    end
  end
end

class Array
  def densities
    collect { |element| count(element) }
  end
end