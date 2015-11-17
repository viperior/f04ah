# Fallout 4 AH v1.0

class Candidate
  def initialize(text)
    @text = text
    @likeness             # Likeness value to actual password.
    @eligible = true      # True until eliminated.
  end

  def compare(candidate)
    # Determine the likeness this candidate has with another.

    likeness = 0

    i = 0
    loop do
      if @text[i] == candidate[i]
        likeness = likeness + 1
      end
      i = i + 1
      break if i == @text.length
    end

    return likeness
  end

  def disable()
    @eligible = false
  end

  def eligible()
    return @eligible
  end

  def set_likeness(likeness)
    @likeness = likeness

    # If likeness is given a value, that means it is not
    # the correct password, so it must be eliminated.
    @eligible = false
  end

  def likeness()
    return @likeness
  end

  def text()
    return @text
  end
end

def eliminate_others(current_choice, choice_likeness, candidates)

  # No matter what likeness value the current choice has, since it was not
  # the correct password, it must be eliminated before proceeding.
  candidates.each do |i|
    if choice_likeness < current_choice.length
      i.disable if current_choice == i.text
    end
  end

  if choice_likeness == 0

    # Any other candidates that share any likeness with
    # this candidate are incorrect.

    # Loop through candidate list, check each one's likeness
    # compared to the current choice.

    # If that likeness is 1 or more, disable that candidate.

    puts "Processing..."
    candidates.each do |i|
    puts "Evaluating current choice, #{current_choice}, against #{i.text}"
      if i.eligible
        i.disable if i.compare(current_choice) >= 1
      end
    end

  else
    # Likeness value of current candidate is n, where n > 0

    # Only candidates that have an equal or greater likeness value
    # with this choice are correct.

    candidates.each do |i|
      if i.eligible
        i.disable if i.compare(current_choice) < choice_likeness
      end
    end

  end

  return candidates
end

def get_starting_candidates_from_user()
  flag = 0
  count = 0
  candidates = []

  puts "Enter a starting candidate and press ENTER. Enter 0 when done."

  loop do
    current_input = gets.chomp
    if current_input != "0"
      count = count + 1
      candidates.push( Candidate.new(current_input) )
    end
    puts "You entered \"#{current_input}\". Total candidates entered: #{count}."
    break if current_input == "0"
  end

  if count > 0
    puts "Candidates entered:"
    candidates.each do |i|
      puts i.text
    end
  end

  return candidates
end

def try_candidates(candidates)
  flag = "0"
  space = " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

  # Calculate the number of remaining candidates
  remaining_candidates = 0
  candidates.each do |i|
    if i.eligible
      remaining_candidates = remaining_candidates + 1
    end
  end

  puts space
  puts "You may now start attempting passwords."
  puts "One at a time, enter a possible password from the list of remaining "
  puts "password candidates. Then, enter the Likeness value returned by the "
  puts "terminal. This program will narrow down the remaining options after "
  puts "each input."

  loop do
    puts "Enter a possible password:"
    current_input_candidate = gets.chomp
    puts "You entered \"#{current_input_candidate}\""

    if current_input_candidate != flag
      puts "Likeness value for \"#{current_input_candidate}\":"
      current_input_likeness = (gets.chomp).to_i
      puts "#{current_input_candidate} has a likeness of #{current_input_likeness}"

      # Eliminate current candidate and all impossible candidates
      candidates = eliminate_others(current_input_candidate, current_input_likeness, candidates)

      # Calculate the number of remaining candidates
      remaining_candidates = 0
      candidates.each do |i|
        if i.eligible
          remaining_candidates = remaining_candidates + 1
        end
      end

      puts space
      puts "New possible candidates:"
      candidates.each do |i|
        puts i.text if i.eligible
      end

    end

    break if current_input_candidate == flag || remaining_candidates <= 1
  end
end

candidates = get_starting_candidates_from_user()
try_candidates(candidates)
