# Hangman Game
#
# *******************************************************************************
# INPUTS:
#   5desk.txt for random dictionary word
#   User input for playing the game
#
# OUTPUTS:
#   Visual counter/ progress of the game
#   Option to save
#   Option to load
#
# KNOWNS:
# HOW TO PLAY:
#   1. A word is chosen at random from the provided dictionary of words.
#   2. The word length is shown using '_' as a placeholder for the 
#   unknown letters of the word. For example, if the word was "cookie",
#   the program would present the player with "_ _ _ _ _ _" so that the player
#   could see the length of the word and the letters that have been guessed
#   correctly.
#   3. The player guesses a letter a-z, and if the letter is in the word, it
#   is shown in the correct blank space. Using the same example for above if
#   the player guessed "c" the screen would update with "c _ _ _ _ _". If the
#   player guesses an incorrect letter, they get a strike against them. Usually
#   visualized by drawing a segment of a hangman's scaffold, and the body parts
#   of a man being hung.
#   4. Play continues until the player has either correctly filled in the blanks
#   of the unknown word or gets "hung" but making too many incorrect guesses.
#
# OBJECTIVES
# - Create the ability to play hangman.
# - Add a save function to the game after it has started.
# - Add a load function to the beginning of the game
# *******************************************************************************
require "yaml"

class Hangman
    attr_reader :word
    attr_accessor :chances, :hang_word, :wrong_letters

    def initialize()
        @word = choose_word
        @hang_word = create_hang_word
        @wrong_letters = []
        @chances = 6
    end

    def save_game
        dir_length = Dir.entries("#{__dir__}/saved_games/").length - 1
        filename = "game #{dir_length}"
        yaml = YAML::dump(self)
        path = File.join(File.dirname(__FILE__), "/saved_games/#{filename}.yaml")
        rdfile = File.new(path, "w+")
        rdfile.write(yaml)
        rdfile.close
    end

    def choose_word
        words = File.readlines "5desk.txt"
        words[rand(words.length - 1)].downcase
    end

    def create_hang_word
        ans = []
        (word.length - 1).times {ans << "_" }
        ans
    end       

    def draw_game
        puts "Word to Guess: #{hang_word}\n"
        puts "Incorrect Letters: #{wrong_letters}\n"
        puts "Chances Left: #{chances}"
    end

    def check_letter(letter)
        found = 0
        index = 0
        puts letter
        if letter == "save"
            return false
        else
            word.each_char do |check|
                if letter == check
                    hang_word[index] = letter 
                    found += 1
                end
                index += 1
            end

            if found == 0
                wrong_letters << letter  
                @chances -=  1
                puts chances
            end
        end
    end

    def get_letter
        while true
            puts "Letter to guess, or 'save'?"
            input = gets.chomp.downcase
            if (wrong_letters.include?(input)) || (hang_word.include?(input))
                puts "You have already guessed that letter"
            elsif input == "save"
                save_game
                return input
            elsif input !~ /[a-z]/
                puts "That is not a letter."
            else
                return input
            end
        end
    end

    def check_ans
      if hang_word.include?( "_") == false
        puts "Congratulations, you have solved it!"
        true
      end
    end

end

def load_game
    while true
        array = []
        puts "what is the file you want to load?"
        filename = gets.chomp
        path = File.join(File.dirname(__FILE__), "/saved_games/", "#{filename}")
        puts path
        if File.exist?(path)
            game_file = File.new(path)
            yaml = game_file.read
            return YAML::load(yaml)
        else
            puts "There is no such file."
        end
    end
end

def load_check
    while true
        puts "Do you want a new game or to load a previously saved game? [ng, load]"
        input = gets.chomp
        case input
        when "ng"
            return Hangman.new
        when "load"
            return load_game
        else
            puts "That is not an option."
        end
    end
end




game = load_check
while game.chances > 0
    game.draw_game
    if game.check_letter(game.get_letter) == false
        puts "game is saved"
        break
    end
    break if game.check_ans
end

if game.chances == 0
    puts "Better luck next time. The word was #{game.word}"
end
