# Fallout 4 AH v1.0.1

# Candidate class is for individual password candidates.
class Candidate
  attr_accessor :attempted, :eligible, :likeness, :text
  def initialize(text)
    @attempted = false    # Candidate has been previously attempted.
    @text = text
    @eligible = true      # True until eliminated.
  end

  def compare(candidate)
    # Determine the likeness this candidate has with another.
    likeness = 0

    @text.length.times do |i|
      likeness += 1 if @text[i] == candidate[i]
    end

    likeness
  end

  def likeness=(likeness)
    @likeness = likeness
    @attempted = true
    # If the candidate has a likeness value, it is not the correct password.
    @eligible = false
  end
end

# CandidateList class is for a list of Candidate objects.
class CandidateList
  attr_accessor :candidates
  def initialize
    @candidates = []
  end

  def add_candidate(text, flag)
    return false if text == flag
    @candidates.push(Candidate.new(text))
  end

  def attempted_candidates
    attempted_candidates = []

    @candidates.each do |i|
      attempted_candidates.push(i) if i.attempted
    end

    attempted_candidates
  end

  def eliminate_based_on_likeness(candidate, likeness)
    if likeness == 0
      eliminate_like_candidates(candidate)
    else
      eliminate_nonequal_candidates(candidate, likeness)
    end
  end

  def eliminate_historically_invalid_candidates(candidate)
    # Check each remaining candidate against all previously attempted
    # candidates. Only candidates that have matching likeness to EACH of the
    # previously tried candidates are valid.
    attempted_candidates.each do |i|
      candidate.eligible = false unless candidate.compare(i.text) == i.likeness
    end
  end

  def eliminate_like_candidates(candidate)
    @candidates.each do |i|
      i.eligible = false if i.compare(candidate) >= 1
    end
  end

  def eliminate_nonequal_candidates(candidate, likeness)
    # Likeness value of current candidate is n, where n > 0. Only candidates
    # that have an equal likeness value with this choice are correct.
    @candidates.each do |i|
      i.eligible = false if i.compare(candidate) != likeness
    end
  end

  def eliminate_options(candidate, likeness)
    # Set the likeness of the current choice. This also disables it by default.
    likeness(candidate, likeness)

    @candidates.each do |i|
      next unless i.eligible
      eliminate_based_on_likeness(candidate, likeness)
      eliminate_historically_invalid_candidates(i)
    end
  end

  def eligible_candidates
    eligible_candidates = []

    @candidates.each do |i|
      eligible_candidates.push(i) if i.eligible
    end

    eligible_candidates
  end

  def index_by_text(text)
    # Returns the index of the element with @text == text
    @candidates.index { |candidate| candidate.text == text }
  end

  def likeness(text, likeness)
    @candidates[index_by_text(text)].likeness = likeness
  end

  def show_all_candidates
    return false if @candidates.length > 0
    puts 'Candidates:'
    @candidates.each do |i|
      puts "#{i.text}"
    end
  end

  def show_eligible_candidates
    puts 'Possible candidates:'
    eligible_candidates.each do |i|
      puts i.text
    end
  end

  def starting_candidates_from_user
    current_input = nil

    puts '', 'Enter a starting candidate and press ENTER. Enter 0 when done.'
    while current_input != '0'
      current_input = gets.chomp
      add_candidate(current_input, '0')
      output = "You entered \"#{current_input}\". Candidates entered: "\
               "#{@candidates.length}. Next candidate:"
      puts output
    end
  end

  def try_candidates
    current_input = nil
    while eligible_candidates.length > 1 && current_input != '0'
      puts 'Enter a possible password:'
      current_input = gets.chomp
      puts "Likeness value for \"#{current_input}\":"
      likeness = (gets.chomp).to_i
      eliminate_options(current_input, likeness)
      puts
      show_eligible_candidates
    end
  end
end

candidate_list = CandidateList.new
candidate_list.starting_candidates_from_user
candidate_list.show_all_candidates
candidate_list.try_candidates
