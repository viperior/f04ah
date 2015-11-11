# This program will take a list of strings that represent
# potential condidates for passwords on a Fallout 4 terminal.
# Then one string and corresponding "likeness" integer can be input.
# Based on the string/likeness pairs entered, it will eliminate
# candidates that cannot be the password.

class Candidate
  def initialize(text)
    @text = text
  end

  def set_likeness(likeness)
    @likeness = likeness
  end

  def set_validity(validity)
    @validity = validity
  end

  def get_text()
    return @text
  end

  def get_likeness()
    return @likeness
  end

  def get_validity()
    return @validity
  end

  def disable()
    set_validity(false)
  end

  def show()
    puts "#{@text}, #{@likeness}, #{@validity}"
  end
end

def calculate_likeness(a, b)
  length = a.length
  likeness = 0

  for i in 0..(length-1)
    if a[i] == b[i]
      likeness = likeness + 1
    end
  end

  return likeness
end

def input_candidates(arr)
  flag = "0"
  counter = 0

  loop do
    puts "Enter password candidate and press Enter. 0 to finish."
    puts "Enter candidate ##{counter+1}"
    current_input = gets.chomp
    if current_input != flag
      current_candidate = Candidate.new(current_input)
      arr.push(current_candidate)
      counter = counter + 1
    end
    break if current_input == flag
  end

  puts "#{counter} candidates collected!"

  return arr
end

def eliminate_candidates(arr)
  # This function accepts one candidate and likeness value pair at a time,
  # disables candidates based on how they compare and the logical
  # possibilities, displays the remaining candidates that are valid

  flag = "0"

  loop do
    puts "Enter a candidate you have attempted. Enter #{flag} to stop."
    current_input = gets.chomp
    if current_input != flag
      current_candidate = current_input
      puts "Enter the Likeness value of this candidate."
      current_input = gets.chomp
      current_likeness = Integer(current_input)

      if current_likeness == 0
        # Rule out any other candidates that have any likeness to this one.
        # Loop through the list of candidates.
        # For each one, except for the current candidate, do a likeness check.
        # If likeness > 0, disable that candidate.
        arr.each do | x |
          if ( x.get_text() != current_candidate ) and ( calculate_likeness(x.get_text, current_candidate) > 0 )
            x.disable()
            puts "#{current_candidate} has been disabled."
          end
        end
      end

    end
    break if current_input == flag
  end

  return arr
end

candidates = Array.new

puts "Welcome to the Fallout 4 Aut0h@ck3r"
candidates = input_candidates(candidates)
candidates = eliminate_candidates()
