=begin
All the code to use this program is provided underneath the two classes
The first block takes all input files and compares them to all expected output files
The second block allows you to individually compare an input file to an expected output file
The third allows you to input your own in the terminal
To use, just ensure you have the two folders of inputs and expecteds in the same folder as the program
=end

require 'json'
require 'matrix'

class DataProcessor
  def initialize(file_path=nil, input_data = nil)
    @file_path = file_path
    @input_data = input_data
  end

  def read_file
    @input_data = File.readlines(@file_path, chomp: true)
  end

  def process_data
    new_data = []
    @input_data.map! do |element|
      new_data.concat(split(element))
    end
    @input_data = new_data

    @input_data.map! do |element|
      if element.match(/^[-+]?\d+$/)
        element.to_i
      elsif element.match(/^[-+]?\d+\.\d+$/)
        element.to_f
      elsif (element == "true")
        element = true
      elsif (element == "false")
        element = false
      elsif (element[0] == "[")
        element = JSON.parse(element)
      else
        element
      end
    end
  end

  def split(input)
    new_input = []
    indv_vals = ""
    string = false
    matrix_count = 0
    lambda_val = false
    input.chars.each_with_index do |char, i|
      # When working on a string, keep addign elements until closing quote is found
      if(string == true)
        indv_vals << char
        if(char == "\"")
          new_input << indv_vals
          indv_vals = ""
          string = false
          next
        else
          next
        end
      end

      # When working on a lambda, keep adding elements until closing } is found
      if(lambda_val == true)
        indv_vals << char
        if(char == "}")
          new_input << indv_vals
          indv_vals = ""
          lambda_val = false
          next
        else
          next
        end
      end

      # When working on a matrix, check char, adjust count if bracket, add to inputs if a completed matrix
      if(matrix_count != 0)
        indv_vals << char
        if(char == "[")
          matrix_count += 1
        elsif(char == "]")
          matrix_count -= 1
        end
        if(matrix_count == 0)
          new_input << indv_vals
          indv_vals = ""
        end
        next
      end

      # Not a string or matrix, but a white space, should seperate element
      if(char == " ")
        if(indv_vals == "")
          next
        end
        new_input << indv_vals
        indv_vals = ""
        next
      end

      if char == "\""
        indv_vals << char
        string = true
      elsif char == "{"
        indv_vals << char
        lambda_val = true
      elsif char == "["
        indv_vals << char
        matrix_count += 1
      else
        indv_vals << char
      end
    end

    if indv_vals != ""
      new_input << indv_vals
    end
    new_input
  end

  def get_input_data
    @input_data
  end

  def display_data
    p @input_data
  end
end

class StackOperations
  def initialize(input, lambda_string = nil)
    @stack_input = input
    @stack = []
    @lambda_string = lambda_string
  end

  def process_stack
    @stack_input.each do |element|

      # EVAL statement goes first, so case/when can be run with correct expression
      if element == "EVAL"
        element = @stack.pop
      end

      case element

      # Add strings, ints, and bools to stack
      when Integer, Float, Array, true, false, /^"[^"]*"$/
        @stack.push(element)

      when /^'/
        remainder = element.sub(/^'/, '')
        if remainder.match(/^[-+]?\d+$/)
          remainder = remainder.to_i
        elsif remainder.match(/^[-+]?\d+\.\d+$/)
          remainder = remainder.to_f
        elsif (remainder == "true")
          remainder = true
        elsif (remainder == "false")
          remainder = false
        end
        @stack.push(remainder)

      # Run operator, but only when top two elements are both ints/floats, or both bools
      when "^"
        if(valid_int_float_pair(@stack) || valid_bool_pair(@stack))
          @stack = operator(@stack, element)
        else
          puts ("Error: Can only compare two Integers or two Booleans using \"" + element + "\"")
        end

      when "*"
        if(valid_int_float_pair(@stack) || valid_array_pair(@stack))
          @stack = operator(@stack, element)
        elsif(valid_string_integer_pair(@stack))
          @stack = operator(@stack, element)
          @stack = clean_string_output(@stack)
        else
          puts ("Error: Can only compare two Integers or a String/Integer pair using \"" + element + "\"")
        end
        

      when "+"
        if(valid_int_float_pair(@stack) || valid_array_pair(@stack))
          @stack = operator(@stack, element)
        elsif(valid_string_pair(@stack))
          @stack = operator(@stack, element)
          @stack = clean_string_output(@stack)
        else
          puts ("Error: Can only compare two Integers two Strings using \"" + element + "\"")
        end

      when "x"
        if(valid_array_pair(@stack))
          @stack = operator(@stack, element)
        end

      when "TRANSP"
        if(@stack.last.is_a?(Array))
          @stack = transpose(@stack)
        end


      # Run operators, but only when top two elements are both strings, or both ints/floats
      when "==", "!=", ">", "<", ">=", "<=", "<=>"
        if(valid_int_float_pair(@stack) || valid_string_pair(@stack))
          @stack = operator(@stack, element)
        else
          puts ("Error: Can only compare two Integers or two Strings using \"" + element + "\"")
        end

      # Run operators, but only when top two elements are both ints or floats
      when "-", "/", "**", "%", "<<", ">>"
        if(valid_int_float_pair(@stack))
          @stack = operator(@stack, element)
        else
          puts ("Error: Can only compare two Integers using \"" + element + "\"")
        end
      
      # Run operators, but only when top two elements are both bools
      when "&", "|"
        if(valid_bool_pair(@stack))
          @stack = operator(@stack, element)
        else
          puts ("Error: Can only compare two Booleans using \"" + element + "\"")
        end

      # Swaps top two elements (no checking required)
      when "SWAP"
        @stack = swap(@stack)

      # Deletes top element (no checking required)
      when "DROP"
        @stack = drop(@stack)

      # Duplicates top element (no checking required)
      when "DUP"
        @stack = duplicate(@stack)

      # Rotates top three elements (no checking required)
      when "ROT"
        @stack = rotate(@stack)

      # Rotates top n elements (checks top value is an int)
      when "ROLL"
        if(@stack.last.is_a?(Integer))
          @stack = rotate(@stack, @stack.pop)
        else
          puts ("Error: Must have an Integer at top of the stack when using \"" + element + "\"")
        end
      
      # Rotates top n elements anticlockwise (checks top value is an int)
      when "ROLLD"
        if(@stack.last.is_a?(Integer))
          @stack = rotate(@stack, @stack.pop, false)
        else
          puts ("Error: Must have an Integer at top of the stack when using \"" + element + "\"")
        end
      
      # Deletes second or third (from top) element based on top element (checks top is bool)
      when "IFELSE"
        if(@stack.last == true || @stack.last == false)
          @stack = ifelse(@stack)
        else
          puts ("Error: Must have an Boolean at top of the stack when using \"" + element + "\"")
        end

      # Wither inverts or gets the ones complement of the top element
      when "!", "~"
        top = @stack.pop
        @stack.push top.send(element)

      # Calculates the value of a lambda, and pushes to the stack
      when /^\{.*\}$/
        @stack = lambda_calc(@stack, element)
      
      # Adds the string version of a lambda to the stack
      when "SELF"
        @stack.push(@lambda_string)

      else
        p ("INVALID ARGUMENT")
      end
    end
  end


  def operator(stack, op)
    if(stack.last.is_a?(Array))
      stack.push(matrix_operation(stack, op))
      return stack
    end
    first = stack.pop
    second = stack.pop
    result = second.send(op, first)
    stack.push(result)
    return stack
  end

  def matrix_operation(stack, op)
    first = stack.pop
    second = stack.pop
    first = set_type(first)
    second = set_type(second)
    output = []
    case op
    when "+"
      if(first.is_a?(Vector) && second.is_a?(Vector) && first.size == second.size)
        output = (first + second).to_a
      elsif(first.is_a?(Matrix) && second.is_a?(Matrix) && first.row_size == second.row_size && first.column_size == second.column_size)
        output = (first + second).to_a
      else
        p "Invalid Matrix/Vector input for addition"
      end

    when "*"
      if(first.is_a?(Matrix) && second.is_a?(Matrix) && first.column_size == second.row_size)
        output = (second * first).to_a
      elsif(second.is_a?(Matrix) && first.is_a?(Vector) && second.column_size == first.size)
        output = (second * first).to_a
      elsif(second.is_a?(Vector) && first.is_a?(Matrix) && second.size == first.row_size)
        output = (second * first).to_a
      elsif(first.is_a?(Vector) && second.is_a?(Vector) && first.size == second.size)
        output = second.inner_product(first)
      else
        p "Invalid Matrix/Vector input for multiplication/dot"
      end

    when "x"
      if(first.is_a?(Vector) && second.is_a?(Vector) && first.size == second.size)
        output = second.cross_product(first).to_a
      else
        p "Invalid Vector input for cross product"
      end
    end
    return output
  end

  def transpose(stack)
    array = stack.pop
    array = set_type(array)
    if(array.is_a?(Matrix))
      stack.push(array.transpose.to_a)
    elsif(array.is_a?(Vector))
      array = Matrix(array)
      stack.push(array.transpose.to_a)
    else
      p "Invalid Matrix/Vector input for transpose"
    end
  end

  def set_type(array)
    if array.all?{|x| !x.is_a?(Array)}
      return Vector[*array]
    elsif array.all?{|x| x.is_a?(Array) && x.length == array.first.length}
      return Matrix[*array]
    else
      return nil
    end
  end

  def swap(stack)
    first = stack.pop
    second = stack.pop
    stack.push(first)
    stack.push(second)
    return stack
  end

  def drop(stack)
    stack.pop
    return stack
  end

  def duplicate(stack)
    return stack.push(stack.last)
  end

  def rotate(stack, num=3, clockwise=true)
    rotate_vals = []
    num.times do
      rotate_vals << stack.pop
    end
    if(clockwise)
      rotate_vals.unshift(rotate_vals.pop).reverse!
    else
      rotate_vals.reverse!.unshift(rotate_vals.pop)
    end
    return stack.push(*rotate_vals)
  end

  def ifelse(stack)
    check = stack.pop
    second = stack.pop
    if(!check)
      third = stack.pop
      stack.push(second)
    end
    return stack
  end

  def lambda_calc(stack, lam)
    params = []
    original_lam = lam
    lam = lam.slice(1, lam.length-2)
    subset = DataProcessor.new(nil, [lam])
    subset.process_data
    lambda_expression = subset.get_input_data\
    
    for i in 1..lambda_expression[0]
      params << @stack.pop
    end
    params = params.reverse
    lambda_expression.map! do |element|
      for j in 1..params.length
        if element == ("x" + (j-1).to_s)
          element = params[j-1]
        end
      end
      element
    end
    lambda_expression = lambda_expression[2..]
    lambda_stack = StackOperations.new(lambda_expression, original_lam)
    lambda_stack.process_stack
    return stack.concat(lambda_stack.get_stack)
  end

  def valid_int_float_pair(stack)
    last_two_elements = stack.last(2)
    if((last_two_elements[0].is_a?(Integer) || last_two_elements[0].is_a?(Float)) && (last_two_elements[1].is_a?(Integer) || last_two_elements[1].is_a?(Float)))
      return true
    else
      return false
    end
  end

  def valid_bool_pair(stack)
    last_two_elements = stack.last(2)
    if((last_two_elements[0]== true || last_two_elements[0] == false) && (last_two_elements[1] == true || last_two_elements[1] == false))
      return true
    else
      return false
    end
  end

  def valid_string_pair(stack)
    last_two_elements = stack.last(2)
    if(last_two_elements[0].match(/^"[^"]*"$/) && last_two_elements[1].match(/^"[^"]*"$/))
      return true
    else
      return false
    end
  end

  def valid_string_integer_pair(stack)
    last_two_elements = stack.last(2)
    if((last_two_elements[0].match(/^"[^"]*"$/) && last_two_elements[1].is_a?(Integer)) || (last_two_elements[1].match(/^"[^"]*"$/) && last_two_elements[0].is_a?(Integer)))
      return true
    else
      return false
    end
  end

  def valid_array_pair(stack)
    last_two_elements = stack.last(2)
    if(last_two_elements[0].is_a?(Array) && last_two_elements[1].is_a?(Array))
      return true
    else
      return false
    end
  end

  def clean_string_output(stack)
    string = stack.pop
    stack.push("\"#{string.gsub('"', '')}\"")
    return stack
  end


  def get_stack
    @stack
  end

end

=begin
# Block that compares all inputs to their expected outputs
inputs = []
ex_outputs = []

Dir.glob("input/input-*.txt").each do |file|
  input = DataProcessor.new(file)
  input.read_file
  input.process_data
  inputs << input.get_input_data
end

Dir.glob("expected/expected-*.txt").each do |file|
  expected = DataProcessor.new(file)
  expected.read_file
  expected.process_data
  ex_outputs << expected.get_input_data
end

for i in 0..inputs.length-1
  stack = StackOperations.new(inputs[i])
  stack.process_stack
  if(stack.get_stack == ex_outputs[i])
    p "Input: " + i.to_s + ":   was CORRECT"
  else
    p inputs[i]
  end
end
=end

=begin
# Block that compares one input to one expected output
expected = DataProcessor.new("expected/expected-260.txt")
expected.read_file
expected.process_data
ex_data = expected.get_input_data


input = DataProcessor.new("input/input-260.txt")
input.read_file
input.process_data
data = input.get_input_data

stack = StackOperations.new(data)
stack.process_stack

puts "\nInput:"
p data

puts "\nOutput:"
p stack.get_stack

puts "\nExpected Ouput:"
p ex_data

puts "\nMatches:"
p stack.get_stack == ex_data
=end


# Block to input your own operators, operands and commands
puts "Enter a valid input:\n"
user_input = [gets.chomp]
input = DataProcessor.new(nil, user_input)
input.process_data
data = input.get_input_data

stack = StackOperations.new(data)
stack.process_stack

puts "\nInput:"
p data

puts "\nOutput:"
p stack.get_stack



