CODE_LENGTH = 4
COLOR_RANGE = 1..6
MAX_TURNS = 12

def generate_secret_code
  Array.new(CODE_LENGTH) { rand(COLOR_RANGE) }
end

def get_valid_input(prompt)
  loop do
    puts prompt
    input = gets.chomp.split.map(&:to_i)
    return input if valid_code?(input)

    puts "Invalid input. Please enter #{CODE_LENGTH} numbers between #{COLOR_RANGE.first}-#{COLOR_RANGE.last}, separated by spaces."
  end
end

def valid_code?(code)
  code.length == CODE_LENGTH && code.all? { |num| COLOR_RANGE.include?(num) }
end

def provide_feedback(secret_code, guess)
  exact_matches = 0
  color_matches = 0
  secret_copy = secret_code.dup
  guess_copy = guess.dup

  guess.each_with_index do |color, index|
    if color == secret_code[index]
      exact_matches += 1
      secret_copy[index] = guess_copy[index] = nil
    end
  end

  guess_copy.compact.each do |color|
    if (index = secret_copy.index(color))
      color_matches += 1
      secret_copy[index] = nil
    end
  end

  { exact_matches: exact_matches, color_matches: color_matches }
end

def play_game
  choice = get_valid_input('Do you want to (1) guess the code or (2) set the code?').first
  choice == 1 ? play_as_guesser : play_as_setter
end

def play_as_guesser
  secret_code = generate_secret_code
  MAX_TURNS.times do |turn|
    puts "\nTurn #{turn + 1}"
    guess = get_valid_input('Enter your guess:')
    feedback = provide_feedback(secret_code, guess)
    display_feedback(feedback)
    return puts "Congratulations! You've cracked the code!" if feedback[:exact_matches] == CODE_LENGTH
  end
  puts "Game over! The secret code was #{secret_code.join(' ')}"
end

def play_as_setter
  secret_code = get_valid_input('Enter your secret code:')
  puts 'Great! The computer will now try to guess your code.'

  previous_guesses = []
  previous_feedback = []

  MAX_TURNS.times do |turn|
    puts "\nTurn #{turn + 1}"
    computer_guess = generate_computer_guess(previous_guesses, previous_feedback)
    puts "Computer's guess: #{computer_guess.join(' ')}"

    feedback = provide_feedback(secret_code, computer_guess)
    display_feedback(feedback)

    previous_guesses << computer_guess
    previous_feedback << feedback

    return puts "The computer has cracked your code in #{turn + 1} turns!" if feedback[:exact_matches] == CODE_LENGTH
  end
  puts "The computer couldn't crack your code in #{MAX_TURNS} turns. You win!"
end

def generate_computer_guess(previous_guesses, previous_feedback)
  all_possible_codes = COLOR_RANGE.to_a.repeated_permutation(CODE_LENGTH).to_a
  return [1, 1, 2, 2] if previous_guesses.empty?

  previous_guesses.zip(previous_feedback).each do |guess, feedback|
    all_possible_codes.select! { |code| provide_feedback(code, guess) == feedback }
  end

  all_possible_codes.first || COLOR_RANGE.to_a.sample(CODE_LENGTH)
end

def display_feedback(feedback)
  puts "Feedback: #{feedback[:exact_matches]} exact matches, #{feedback[:color_matches]} color matches"
end

play_game
