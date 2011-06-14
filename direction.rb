class Direction
	@@directions=["north", "east", "south", "west", "n", "s", "e", "w"]
	def current
		@current
	end
	def initialize(direction)
		begin
			self.current=direction
		rescue
			raise
		end
	end
	def current=(newC)
		newC.downcase!
		puts "current method called" if $DEBUG
		if  @@directions.include?(newC)
			@current=newC[0]
		else
			raise IndexError, "#{newC} is not a valid direction. Must be one of #{@@directions.to_s}"
		end
	end
	def turn!(angle)
		case angle
		when "left", "l"
			case @current
			when "north", "n"
				self.current="west"
			when "west", "w"
				self.current="south"
			when "south", "s"
				self.current="east"
			when "east", "e"
				self.current="north"
			end
		when "right", "r"
			case @current
			when "north", "n"
				self.current="east"
			when "east", "e"
				self.current="south"
			when "south", "s"
				self.current="west"
			when "west", "w"
				self.current="north"
			end
		end
	end

	def ==(direction)
		self.current == direction.current
	end
end
