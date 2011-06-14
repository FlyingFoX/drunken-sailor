#!/usr/bin/ruby
require 'test/unit'
require './direction'

class DirectionInitializationTest < Test::Unit::TestCase
	def test_initialize
		assert_nothing_raised{ 
			direction = Direction.new( "north")
		}
		assert_nothing_raised{
			direction = Direction.new( "east")
		}
		assert_nothing_raised{
			direction = Direction.new( "south")
		}
		assert_nothing_raised{
			direction = Direction.new( "west")
		}
		assert_nothing_raised{
			direction = Direction.new( "e")
		}
		assert_raises( IndexError){
			direction = Direction.new( "northern")
		}
	end
end

class DirectionTest < Test::Unit::TestCase
	def setup
		@direction = Direction.new("w")
		@EAST = Direction.new("e")
		@WEST = Direction.new("w")
		@NORTH = Direction.new("n")
		@SOUTH = Direction.new("s")
	end

	def test_currentEast
		@direction.current = "e"
		assert_equal( @direction, @EAST )
		@direction.current = "east"
		assert_equal( @direction, @EAST )
	end
	def test_currentSouth
		@direction.current = "south"
		assert_equal( @direction, @SOUTH)
	end
	def test_currentWest
		@direction.current = "west"
		assert_equal( @direction, @WEST)
	end
	def test_currentNorth
		@direction.current = "n"
		assert_equal( @direction, @NORTH)
	end
	def test_current_error
		assert_raises( IndexError){
			@direction.current= "not a direction"
		}
	end
	def test_turn
		@direction.turn!("left")
		assert_equal(@direction, @SOUTH )
		@direction.turn!("left")
		assert_equal(@direction, @EAST )
		@direction.turn!("right")
		assert_equal(@direction, @SOUTH )
		@direction.current="north"
		@direction.turn!("right")
		assert_equal(@direction, @EAST )
		@direction.current="north"
		assert_nothing_raised{@direction.turn!("forward")}
		assert_equal(@direction, @NORTH)
		@direction.current = "south"
		assert_nothing_raised{@direction.turn!("stay")}
		assert_equal(@direction, @SOUTH)
	end

end
