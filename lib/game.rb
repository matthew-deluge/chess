# game class, creates a new board and allows for the movement and capture of pieces

require_relative "./board"
require_relative "./instructions"


class String
  def is_integer?
    self.to_i.to_s == self
  end
end

# class with the game loop and win conditions
class Game
  include Instructions
  require 'yaml'
  attr_accessor :board

  def initialize
    @board = Board.new
    @board.set_pieces
    @current_player = 'white'
  end

  def play
    print_instructions
    until checkmate?
      player_move
    end
    puts "Congrats #{current_player}, you have checkmated your opponent, nice work!"
  end

  def save_file
    save_object = YAML::dump(@board)
    File.open('save_data.yml', 'w') { |file| file.write(save_object) }
    puts 'File saved, see you again soon!'
    exit
  end

  def load_file
    file = File.read('save_data.yml')
    @board = YAML::load(file)
    puts "Welcome back!"
    @board.print_board(@board)
  end

  private

  def clear_screen
    print "\e[2J\e[f"
  end

  def player_move(board = @board)
    clear_screen
    board.print_board(board)
    player_move = get_player_move
    board.move(player_move[0], player_move[1])
    @current_player == 'white' ? @current_player = 'black' : @current_player = 'white'
  end

  def get_player_move
    player_move = [get_piece, get_move]
    until board.clear_path?(player_move[0], player_move[1]) && !move_in_check?(@current_player, player_move[0], player_move[1], board)
      puts 'Illegal move!'
      player_move = [get_piece, get_move]
    end
    player_move
  end

  def get_piece
    puts "#{@current_player.capitalize()}, please put the coordinates of the piece you want to move"
    player_input = gets.chomp
    save_file if player_input.downcase == 'save'
    until valid_response?(player_input)
      puts 'please enter the coordinates as two numbers seperated by a comma'
      player_input = gets.chomp
    end
    while board.find_square(convert_to_coordinates(player_input)).piece.nil? || @board.find_square(convert_to_coordinates(player_input)).piece.color != @current_player
      puts 'please select a piece of your color'
      player_input = gets.chomp
    end
    convert_to_coordinates(player_input)
  end

  def get_move
    puts 'Please enter the coordinates of where you want to move your piece:'
    player_input = gets.chomp
    until valid_response?(player_input)
      puts "\nPlease enter the coordinates as two numbers seperated by a comma"
      player_input = gets.chomp
    end
    convert_to_coordinates(player_input)
  end

  def convert_to_coordinates(input)
    return input if input.is_a?(Array)

    split_input = input.strip.split(',')
    split_input.each_with_index { |number, index| split_input[index] = number.to_i }
    split_input
  end

  def valid_response?(input)
    return false unless input.include?(',')

    split_input = input.strip.split(',')
    if split_input.length == 2 && split_input[0].is_integer? && split_input[1].is_integer?
      return split_input[0].to_i >= 1 && split_input[0].to_i <= 8 && split_input[1].to_i >= 1 && split_input[1].to_i <= 8
    end
    false
  end

  def move_in_check?(player_color, player_piece, player_move, board=@board)
    board_copy = board.copy_board
    board_copy.move(player_piece, player_move)
    board_copy.node_array.each do |square|
      if !square.piece.nil? && square.piece.is_a?(King)
        return true if square.piece.check?(square.coord, board_copy) && square.piece.color == player_color
      end
    end
    false
  end

  def checkmate?
    @board.node_array.each do |square|
      unless square.piece.nil? 
        if square.piece.is_a?(King)
          return true if square.piece.checkmate?(square.coord, @board)
        end
      end
    end
    false
  end

  def black_turn?
    board.find_square(board.move_array[-1][1]).piece.color == 'white'
  end
end