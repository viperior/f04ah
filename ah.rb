# Fallout 4 AH v1.0

class Candidate
  def initialize(text)
    @attempted = false    # Candidate has been previously attempted.
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

  def set_likeness(likeness)
    @likeness = likeness
    @attempted = true
    #If the candidate has a likeness value, it is not the correct password.
    disable()
  end

  def attempted()
    return @attempted
  end

  def eligible()
    return @eligible
  end

  def likeness()
    return @likeness
  end

  def text()
    return @text
  end
end

class CandidateList
  def initialize()
    @candidates = []
    @eligible_count
  end

  def calculate_eligible_count()
    @eligible_count = 0

    @candidates.each do |i|
      if i.eligible
        @eligible_count = @eligible_count + 1
      end
    end
  end

  def show_all_candidates()
    puts "Candidates:"
    @candidates.each do |i|
      puts "#{i.text}"
    end
  end

  def show_eligible_candidates()
    eligible_candidates = get_eligible_candidates()

    puts "Possible candidates:"
    eligible_candidates.each do |i|
      puts i.text
    end
  end

  def set_likeness(text, likeness)
    @candidates[ get_index_by_text(text) ].set_likeness(likeness)
  end

  def add_candidate(text)
    @candidates.push( Candidate.new(text) )
    calculate_eligible_count()
  end

  def get_attempted_candidates()
    attempted_candidates = []

    @candidates.each do |i|
      attempted_candidates.push(i) if i.attempted
    end

    return attempted_candidates
  end

  def get_eligible_candidates()
    eligible_candidates = []

    @candidates.each do |i|
      eligible_candidates.push(i) if i.eligible
    end

    return eligible_candidates
  end

  def get_eligible_count()
    calculate_eligible_count()

    return @eligible_count
  end

  def get_index_by_text(text)
    # Returns the index of the element with @text == text

    c = 0
    index = nil
    @candidates.each do |i|
      if text == i.text
        index = c
      end
      c = c + 1
    end

    return index
  end

  def list()
    return @candidates
  end
end

def eliminate_others(current_choice, choice_likeness, candidate_list)
  # Set the likeness of the current choice. This also disables it by default.
  candidate_list.set_likeness(current_choice, choice_likeness)

  candidate_list.list.each do |i|
    if i.eligible
      if choice_likeness == 0
        # Any other candidates that share any likeness with
        # this candidate are incorrect.
        i.disable if i.compare(current_choice) >= 1
      else
        # Likeness value of current candidate is n, where n > 0
        # Only candidates that have an equal likeness value
        # with this choice are correct.
        i.disable if i.compare(current_choice) != choice_likeness
      end

      # Check each remaining candidate against all previously
      # attempted candidates. Only candidates that have matching
      # likeness to EACH of the previously tried candidates
      # are valid.
      candidate_list.get_attempted_candidates.each do |j|
        if !( i.compare(j.text) == j.likeness )
          i.disable
        end
      end
    end
  end

  return candidate_list
end

def get_starting_candidates_from_user()
  flag = "0"
  count = 0
  candidate_list = CandidateList.new()

  puts "Enter a starting candidate and press ENTER. Enter 0 when done."

  loop do
    current_input = gets.chomp
    if current_input != flag
      count = count + 1
      candidate_list.add_candidate( current_input )
    end
    puts "You entered \"#{current_input}\". Total candidates entered: #{count}."
    break if current_input == flag
  end

  if count > 0
    candidate_list.show_all_candidates
  end

  return candidate_list
end

def try_candidates(candidate_list)
  flag = "0"
  space = " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  remaining_candidates = candidate_list.get_eligible_count()

  puts space
  puts "You may now start attempting passwords."
  puts "One at a time, enter a possible password from the list of remaining "
  puts "password candidates. Then, enter the Likeness value returned by the "
  puts "terminal. This program will narrow down the remaining options after "
  puts "each input."

  loop do
    puts "Enter a possible password:"
    current_input_candidate = gets.chomp

    if current_input_candidate != flag
      puts "Likeness value for \"#{current_input_candidate}\":"
      current_input_likeness = (gets.chomp).to_i

      # Eliminate current candidate and all impossible candidates
      candidate_list = eliminate_others(current_input_candidate, current_input_likeness, candidate_list)

      puts space
      candidate_list.show_eligible_candidates
    end

    break if current_input_candidate == flag || candidate_list.get_eligible_count() <= 1
  end
end

candidate_list = get_starting_candidates_from_user()
try_candidates(candidate_list)
