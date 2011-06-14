#!/usr/bin/ruby
require './direction.rb'
class BridgeLeft < StandardError
	attr_writer :state, :message
	attr_reader :state, :message
	@@STATES = {"water" => "We reached	WATER.", "ship" => "We reached SHIP.", "bridge" => "We are still on the bridge."}
	def initialize(state)
		@state, @message = @@STATES.assoc("#{state}")
	end
end

class Position
	#the coordinate system has (0,0) at the bottom left and north is to the top.
	#state tells us if we are still on the bridge, reached the finish or walked into water.
	#the ship is to the north and is reached if we hit any position with Y >15
	#we assume that the bridge is surrounded by water on all 3 other sides,
	#because I don't know a better way to deal with a Position with Y<0
	attr_reader :x, :y
	def initialize(x, y, direction)
		#this is necessary to enable sensemaking error checking in x=()
		@x = x
		@y = y
		#we still do this to have error checking
		begin
			self.x=x
			self.y=y
		rescue
			raise
		end
		begin
			@direction = Direction.new(direction)
		rescue
			raise
		end
	end

	def x=(newX)
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

	def direction
		@direction.current[0]
	end

	def nextStep!(turnTo)
		if turnTo === "stay" then
			#do nothing	
		elsif ["forward", "left", "right"].include?(turnTo) then
			@direction.turn!(turnTo)
			begin
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
			rescue
				raise
			end
		else
			raise IndexError, "turnTo needs to be one of [\"forward\", \"left\", \"right\", \"stay\"] but is #{turnTo}"
		end#else
	end

	def getPosition()
		[@x, @y, self.direction]
	end#getpos
end

class Journey
	#the overall number of times we already fell into water or reached the ship
	@@water = 0
	@@ship = 0
	@@total = 0

	attr_reader :waypoints, :current, :message, :hasEnded
	def Journey.water
		@@water
	end
	def Journey.ship
		@@ship
	end
	def Journey.total
		@@total
	end
	
	def initialize(x = 4, y = 0, direction = "north")
		#we cannot use current.getPosition here because we want 
		#to be able to see the first step of a journey that started
		#with a position outside the bridge and therefore need to 
		#have @waypoints filled before we intialize @current
		#
		@waypoints = Array.new(1, [x, y, direction[0]])
		@hasEnded = false
		begin
			@current = Position.new(x, y, direction)
		rescue BridgeLeft => left
			endReached error
		end
	end

	def endReached error
		case error.state
		when "water"
			@@water += 1
		when "ship"
			@@ship += 1
		end
		@@total += 1
		@message = error.message
		@hasEnded = true
	end

	def run
		if @hasEnded == false
			begin
				#run until we get an error
				while true do
					puts @waypoints.last if $DEBUG
					turnTo = ["left", "right", "forward", "stay"].sample
					@current.nextStep!(turnTo)
					@waypoints.push(@current.getPosition)
				end
			rescue BridgeLeft => error
				endReached error
			end
		end
	end
end

class Simulation
	def simulate(number)
		number.times do
			journey = Journey.new
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

#run the simulation x times.
#
def run x
	sim = Simulation.new
	sim.simulate x
end

if __FILE__ == $0
	run 10
end
