# game class, creates a new board and allows for the movement and capture of pieces

require_relative "./board.rb"


class String
  def is_integer?
    self.to_i.to_s == self
  end
end

# class with the game loop and win conditions
class Game

  attr_accessor :board, :white_captured, :black_captured

  def initialize
    @board = Board.new
    @board.set_pieces
    @white_captured = []
    @black_captured = []
  end

  def player_move(player_color, board = @board)
    board.print_board(board)
    player_move = get_player_move(player_color, board)
    board.move(player_move[0], player_move[1])
    board.print_board(board)
  end

  def get_player_piece(player_color)
    puts "#{player_color}, please enter the coordinates of the piece you want to move:"
    player_input = gets.chomp
    until valid_response?(player_input)
      puts 'please enter the coordinates as two numbers seperated by a comma'
      player_input = gets.chomp
    end
    while board.find_square(convert_to_coordinates(player_input)).piece.nil? || @board.find_square(convert_to_coordinates(player_input)).piece.color != player_color
      puts 'please select a piece of your color'
      player_input = get_player_piece(player_color)
    end
    convert_to_coordinates(player_input)
  end

  def get_player_move(player_color, board=@board)
    player_piece = get_player_piece(player_color)
    puts 'Please enter the coordinates of where you want to move your piece'
    player_input = [player_piece, gets.chomp]
    until valid_response?(player_input[1])
      puts 'Please enter the coordinates as two numbers seperated by a comma'
      player_input = get_player_move(player_color, board)
    end
    until board.clear_path?(player_input[0], convert_to_coordinates(player_input[1]))
      puts 'Invalid destination'
      player_input = get_player_move(player_color, board)
     
    end
    while move_in_check?(player_color, player_input[0], convert_to_coordinates(player_input[1]), board)
      puts 'Illegal move: king in check'
      player_input = get_player_move(player_color, board)
    end
    [player_input[0], convert_to_coordinates(player_input[1])]
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

  def play
    #print instructions
    until checkmate?
      player_move('white')
      player_move('black')
    end
    #endgame
  end
end
  
#game = Game.new
#game.play

    