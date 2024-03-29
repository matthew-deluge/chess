# tests for the board class

require_relative '../lib/board'

describe Board do

  describe '#add_piece' do
    subject(:piece_board) { described_class.new }
    context 'when passed a piece' do
      it 'puts that piece on the correct square' do
        test_piece = Rook.new('white','r')
        piece_board.add_piece([8,8], test_piece)
        expect(piece_board.find_square([8,8]).piece).to be(test_piece)
      end
      it 'leaves other squares alone' do
        test_piece = Rook.new('white','r')
        piece_board.add_piece([8,8], test_piece)
        expect(piece_board.find_square([8,7]).piece).to be(nil)
      end
    end
  end

  describe '#clear_path?' do
    subject(:path_board) {described_class.new}
    context '#when passed a piece with a clear path' do
      it 'returns true' do
        path_board.add_piece([1,1], Rook.new('white', 'r'))
        path_clarity = path_board.clear_path?([1, 1], [1,4])
        expect(path_clarity).to be(true)
      end
    end
    context 'when passed a piece without a clear path' do
      it 'returns false' do
        path_board.add_piece([1, 8], Rook.new('white','r'))
        path_board.add_piece([1, 3], Rook.new('white', 'r'))
        path_clarity = path_board.clear_path?([1,8], [1,1])
        expect(path_clarity).to be(false)
      end
    end
  end

  describe '#set_pieces' do
    subject(:filled_board) {described_class.new}
    context 'when calledd' do
      it 'puts correct pieces in place' do
        filled_board.set_pieces
        expect(filled_board.find_square([1,1]).piece.symbol).to eq('♜')
      end
    end
  end

  describe '#copy_board' do
    subject(:board_to_copy) {described_class.new}
    it 'creates a copy with the same pieces' do
      board_to_copy.add_piece([1,1], Rook.new('white','r'))
      copied_board = board_to_copy.copy_board
      expect(copied_board.find_square([1, 1]).piece.symbol).to eq('r')
    end
  end

  describe '#move' do
    subject(:move_board) {described_class.new}
    context 'when path is open' do
      it 'moves the piece to the target square'do
        move_board.add_piece([1,1], Rook.new('white', 'wr'))
        move_board.move([1, 1], [1, 3])
        expect(move_board.find_square([1, 3]).piece.symbol).to eq('wr')
      end
    end
    context 'when path is not open' do
      it 'does nothing' do
        move_board.add_piece([1,3], Pawn.new('white', 'p'))
        move_board.add_piece([1,7], Rook.new('black', 'r'))
        move_board.move([1,7], [1,1])
        expect(move_board.find_square([1,1]).piece.symbol).to eq('r')
      end
    end  
    context 'when piece would be captured' do
      it 'returns piece' do
        move_board.add_piece([1,1], Pawn.new('white', 'wp'))
        move_board.add_piece([1,7], Rook.new('black', 'br'))
        move_board.move([1, 7], [1, 1])
        expect(move_board.captured_pieces[0].symbol).to eq('wp')
      end
      it 'replaces captured piece with capturing piece' do
        move_board.add_piece([1,1], Pawn.new('white', 'wp'))
        move_board.add_piece([1,8], Rook.new('black', 'br'))
        move_board.move([1, 8], [1, 1])
        expect(move_board.find_square([1, 1]).piece.symbol).to eq('br')
      end
    end

  end

  describe '#promote_pawn' do
    subject(:promote_board) { described_class.new}

    it 'promotes a passed pawn to the passed piece' do
      promote_board.add_piece([1,1], Pawn.new('white', 'p'))
      promote_board.promote_pawn([1,1], 'queen')
      piece = promote_board.find_square([1, 1]).piece.symbol
      expect(piece).to eq('♛')
    end
  end


end
