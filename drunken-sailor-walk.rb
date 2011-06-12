#!/usr/bin/ruby
require './direction.rb'
class BridgeLeft < StandardError
	attr_writer :state, :message
	attr_reader :state, :message
	@@STATES = {"water" => "We reached	WATER.", "ship" => "We reached SHIP.", "bridge" => "We are still on the bridge."}
	def initialize(state)
		puts @@STATES if $DEBUG
		@state, @message = @@STATES.assoc("#{state}")
	end
end

class Position
	#the coordinate system has (0,0) at the bottom left and north is to the top.
	#state tells us if we are still on the bridge, reached the finish or walked into water.
	#the ship is to the north and is reached if we hit any position with Y >15
	#we assume that the bridge is surrounded by water on all 3 other sides,
	#because I don't know a better way to deal with a Position with Y<0
	attr_reader :x, :y, :direction
	def initialize(x, y, direction)
		#this is necessary to enable sensemaking error checking in x=()
		@x = x
		@y = y
		#we still do this to have error checking
		self.x=x
		self.y=y
		@direction = Direction.new(direction)
	end
	def x=(newX)
		puts "x= method called" if $DEBUG
		if not (1..7).include?(@x) then
			puts "water raised" if $DEBUG
			raise BridgeLeft.new("water")
		end
		@x = newX
	end
	def y=(newY)
		if not (0..15).include?(@y) then
			if @y > 15 then
				puts "ship raised" if $DEBUG
				raise BridgeLeft.new("ship")
			elsif @y < 0 then
				puts "water raised" if $DEBUG
				raise BridgeLeft.new("water")
			end
		end
		@y = newY
	end
	def direction=(newD)
		@direction.current=newD
	end

	def nextStep!(turnTo)
		@direction.turn!(turnTo)
		if turnTo === "stay" then
			#do nothing	
		elsif ["forward", "left", "right"].include?(turnTo) then
			case @direction.current
			when "s", "south"
				self.y -= 1
			when "e", "east"
				self.x += 1
			when "n", "north"
				self.y += 1
			when "w", "west"
				self.x -= 1
			end#case
		else
			raise IndexError, "turnTo needs to be one of [\"forward\", \"left\", \"right\", \"stay\"] but is #{turnTo}"
		end#else
	end

	def getPosition()
		[@x, @y]
	end#getpos
end

class Journey
	#the overall number of times we already fell into water or reached the ship
	@@water = 0
	@@ship = 0
	@@total = 0

	attr_reader :waypoints, :current, :water, :ship, :total, :message
	#to initialize with the standard value pass nil for x and y
	def initialize(x = 4, y = 0, direction = "north")
		@current = Position.new(x, y, direction)
		@waypoints = Array.new(1,@current.getPosition)
	end
	def waterReached
		@@water += 1
		@@total += 1
		"water"
	end

	def shipReached
		@@ship += 1
		@@total += 1
		"ship"
	end

	def run
		begin
			#run until we get an error
			while true do
				puts @waypoints.last if $DEBUG
				turnTo = ["left", "right", "forward", "stay"].sample
				@current.nextStep!(turnTo)
				@waypoints.push(@current.getPosition)
			end
		rescue BridgeLeft => error
			case error.state
			when "water"
				waterReached
				@message = error.message
			when "ship"
				shipReached
				@message = error.message
			else
				raise IndexError, "#{error} can't be handled."
			end
		end
	end
end

class Simulation
	def simulate(number)
		number.times do
			journey = Journey.new(nil, nil)
			journey.run
			giveDetails(journey)
		end
		summary()
	end

	def giveDetails(journey)
		puts journey.message
		puts "We went the following path: "
		puts "#{journey.waypoints}"
	end
	def summary
		puts "-" * 10
		puts "We have reached the Ship #{Journey.ship} times out of #{Journey.total} total tries."
		percent = Journey.ship / Journey.total * 100
		puts "This is a success rate of #{percent}%."
	end
end

if __FILE__ == $0
	sim = Simulation.new
	sim.simulate(1)
end
