require 'yaml'

$dictionary = File.read('colors.txt').split(/\n/)


class Controller

	def initialize(dictionary)
		@dictionary = dictionary
		@current_game = nil

		#@guesses_remaining = 10
		#@guess = ''
		#Intro text
		puts "Alright, this is a hangman game.  
		Guess letters to fill in the blanks. 
		You have 10 guesses to start."
	end

	def new_game
		@current_game = Game.new(@dictionary.sample, 10)
		puts "Here's the word cheaty, #{@word}"
		# p word
		@current_game.game_loop
	end

  def prompt_guess
    letter = gets ''
    @current_game.guess(letter)
    if @current_game.last_guess_good?
      puts 'Corrent!'
    else
      puts "WONG!"
    end

    prompt_guess if !@current_game.is_over?
  end

	def prompt_load_saved
		puts	"Would you like to to open a saved game? Type y/n"
		@answer = gets.chomp
		if @answer == "y"
			self.open_saved
		else
			puts "Cool, lets play a new game."
		end
	end

	def prompt_save
		puts "Save game? y/n"
		answer = gets.chomp
		if answer == "y"

			save_game
		else puts "Play on!"
		end
	end

	

	#Save the game to a file   ##load saved games into an array or hash so user can choose by number or index
	def save_game
		puts "Type a name for your saved game"
		game_name = gets.chomp	
		filename = "#{game_name}.yml"

		 ex_file = File.expand_path("./saved_games/#{filename}")
		 
		if File.exists?(ex_file)
	   puts "#{filename} exists" #overwrite method?
	  
	   self.save_game
	  else
			File.open(ex_file, "w") do |f|
				game_state = YAML::dump(self)
				f.puts game_state
				puts "Your game was saved as #{filename}"  
			end
		end
	end


#list contents of saved games directory
#prompt player to choose one of the saved games

	def show_saved
		puts Dir.glob("./saved_games/*")
	end

	def choose_saved
		puts "Enter the name of the game you would like to open, just the last part of the filename before the .txt" ###readfrom file########
		@open_name = gets.chomp
	end

	def open_saved
		 self.show_saved
		
		# file_to_open = File.expand_path("./saved_games/#{@open_name}")


		File.open("./saved_games/pinktest.txt", "r") do |f|
			 game_state = YAML::load_file(f.read)
		end

		# data =  YAML::load_file("./saved_games/redyaml.yml")
		puts game_state

		puts "__________________________"
	end
end #controller class


class Game

  @word = ''
  @guesses = []
  @last_guessed = ''

	def initialize()
    self.word = 'horse'
    @guesses_remaining = 7
	end

	def masked_word
    @masked_word
	end

	def guess(letter)
    # set last_guessed to letter
    @last_guessed = letter
    return false if guesses().include?(letter)

    handle_guess(good_guess?(letter))  #make sure to call vars in context
	end

	def last_guess_good?
    last_guess_good
	end

		#show the correct number of blank spaces
	def show_blanks
		@result_array = "_"*@word_array.length
		puts @result_array
	end

	def prompt_guess
		puts "Guess a letter"
		@guess = gets.chomp
	end

	#alternative to match_letters, use word as first arg and guesses as an array, check each time looping thru word to check if there's a match and put match or leave

	def check_win
		p @guesses_remaining
		if @guesses_remaining == 0
			puts "It's all over, you're out of guesses"
			good_bye
		elsif @word.chomp == @result_array
			puts "Aw yeah.  You win, you wiener!"
			good_bye
		end
	end

	def is_over?
		# puts "guesses = #{@guesses_remaining}, result_array = #{@result_array}"
		(@guesses_remaining == 0 or @word.chomp == @result_array)
	end

	def good_bye
		puts "Thanks for playing"
		exit
	end

  def game_loop

    @current_game.prompt_load_saved

    self.get_word

    self.show_blanks

    while !self.is_over?
      self.prompt_save

      self.prompt_guess

      self.decrement_guesses


      self.check_win

    end
  end

  private

	def handle_guess(good)
    return handle_good_guess() if good

    handle_bad_guess()
	end

	def handle_good_guess
    add_guess(@last_guessed)
    # Update masked word
    @last_guess_good = true
	end

	def handle_bad_guess
    add_guess(@last_guessed)
    decrement_guesses
    @last_guess_good = false
	end

	#checks if players guess is included in word
	def	good_guess?(g)
    word().include?(g)
	end

	#check if the guess matches 1 or more letters and show letters in blanks
	def match_letters #handle_guess
		indexes_matched = @word_array.each_index.select { |i| @word_array[i] == @guess}

		for x in indexes_matched do
			@result_array[x] = guess
		end

		puts @result_array
	end

  def word=(word)
    @word = word
    @masked_word = ("_" * (word.length))
    word
  end

  def word()
    @word
  end

  def masked_word=(word)
    @masked_word = word
  end

  def last_guess_good=(good)
    @last_guess_good = good
  end

  def guesses=(guesses)
    @guesses = guesses
  end

  def guesses()
    @guesses ||= []
  end

  def add_guess(letter)
    @guesses << letter
  end

	def decrement_guesses
		@guesses_remaining = @guesses_remaining - 1
	end
end

#controller = Controller.new($dictionary)
#controller.new_game
# game.game_loop
