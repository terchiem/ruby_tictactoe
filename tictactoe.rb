module SetSpace
  def set(i, j, value)
    if @spaces[i][j].nil?
      @spaces[i][j] = value
      return true
    end
    false
  end

  def clear
    @spaces = Array.new(3){ Array.new(3) }
  end
end

class Board
  include SetSpace

  def initialize
    @spaces = Array.new(3){ Array.new(3) }
  end

  def display
    puts "============="
    @spaces.each do |row|
      row.each { |cell| print " [#{cell.nil? ? " " : cell}]" }
      puts ""
    end
    puts "=============\n\n"
  end

  def each
    @spaces.each { |x| yield(x) }
  end

  def [](key)
    @spaces[key]
  end
end

class Player
  include SetSpace
  def initialize
    @spaces = Array.new(3){ Array.new(3) }
  end

  def check_rows
    @spaces.each do |row|
      return true unless row.include?(nil)
    end
    false
  end

  def check_cols
    3.times do |i|
      return true if @spaces[0][i] && @spaces[1][i] && @spaces[2][i]
    end
    false
  end

  def check_diag
    unless @spaces[1][1].nil?
      if (@spaces[0][0] && @spaces[2][2]) ||
         (@spaces[2][0] && @spaces[0][2])
         return true
      end
    end
    false
  end

  def winner?
    check_rows || check_cols || check_diag
  end
end

class Game
  def initialize
    @player = { "X" => Player.new, "O" => Player.new }
    @board = Board.new
  end

  def start_game
    round = 1
    current_player = "X";

    until game_over?
      puts "Round #{round}"
      @board.display
      puts "#{current_player}'s Turn"

      valid_move = false
      until valid_move
        x, y = prompt_user
        valid_move = @board[x][y].nil?
        puts "Invalid move." unless valid_move
      end

      make_move(x, y, current_player)
      current_player = current_player == "X" ? "O" : "X"
      round += 1
      puts ""
    end

    @board.display
    puts get_result
    puts ""

    new_game if new_game?
  end

  def prompt_user()
    while true
      print "Enter coordinates (x,y): "
      input = gets.chomp
      if input.match?(/^\d\s*,\s*\d$/)
        x, y = input.split(',').map(&:to_i)
        if x.between?(0,2) && y.between?(0,2)
          return [x, y]
        else
          puts "Coordinates out of range."
        end
      else
        puts "Invalid coordinates entered."
      end
    end
  end

  def make_move(x, y, player)
    @board.set(x, y, player)
    @player[player].set(x, y, player)
  end

  def tie?
    @board.each do |row|
      row.each { |cell| return false if cell.nil? }
    end
    true
  end

  def game_over?
    @player["X"].winner? || @player["O"].winner? || tie?
  end

  def get_result
    result = "Tie game!"
    result = "Player 'X' wins!" if @player["X"].winner?
    result = "Player 'O' wins!" if @player["O"].winner?
    result
  end

  def new_game?
    while true
      puts "Play again? (y/n)"
      input = gets.chomp.downcase
      puts ""
      if input.match?(/^[yn]$/)
        return input == "y" ? true : false
      else
        puts "Invalid choice."
      end
    end
  end

  def new_game
    @board.clear
    @player["X"].clear
    @player["O"].clear
    start_game
  end
end

game = Game.new
game.start_game