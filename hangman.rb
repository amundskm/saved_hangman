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
require 'sinatra'

get '/' do
  redirect to '/new' if session["game"].nil?
  redirect to '/new' if session["game"].check_ans
  redirect to '/new' if session["game"].chances == 0
  wrong = "Wrong Letters: #{session["game"].wrong_letters}"
  hang = "Word: #{session["game"].hang_word}"
  misses = "Wrong Letters: #{session["game"].chances}"
  erb :index, :locals => {:wrong_letters => wrong,:hang_word => hang,:chances => misses}

end

get '/new' do
  session["game"] = Hangman.new
  redirect to '/'
end

post '/guess' do
  guess = params["guess"]
  session["game"].check_letter(guess)
  redirect to '/'
end


class Hangman
    attr_reader :word
    attr_accessor :chances, :hang_word, :wrong_letters

    def initialize()
        @word = choose_word
        @hang_word = create_hang_word
        @wrong_letters = []
        @chances = 6
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

    def check_letter(letter)
        found = 0
        index = 0
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
        end

    end

    def check_ans
      if hang_word.include?( "_") == false
        true
      end
    end

end

# def load_game
#     while true
#         array = []
#         filename = gets.chomp
#         path = File.join(File.dirname(__FILE__), "/saved_games/", "#{filename}")
#         puts path
#         if File.exist?(path)
#             game_file = File.new(path)
#             yaml = game_file.read
#             return YAML::load(yaml)
#         end
#     end
# end
#
# def save_game
#     dir_length = Dir.entries("#{__dir__}/saved_games/").length - 1
#     filename = "game #{dir_length}"
#     yaml = YAML::dump(self)
#     path = File.join(File.dirname(__FILE__), "/saved_games/#{filename}.yaml")
#     rdfile = File.new(path, "w+")
#     rdfile.write(yaml)
#     rdfile.close
# end
