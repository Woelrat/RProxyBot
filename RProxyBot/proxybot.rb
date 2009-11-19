## Standard Library requires
require 'socket'
require 'singleton'
## RProxybot requires
require 'util.rb'
require 'player.rb'
require 'unittype.rb'
require 'locations.rb'
require 'map.rb'
require 'techtype.rb'
require 'upgrade_type.rb'

module RProxyBot
	class ProxyBot
		attr_accessor :allow_user_control
		attr_accessor :complete_information

		attr_accessor :map, :player, :enemy, :unit_types,
			:starting_locations, :units, :tech_types,
			:upgrade_types, :command_queue, :max_commands_per_message

		def run(allow_user_control, complete_information)
			self.allow_user_control = allow_user_control
			self.complete_information = complete_information
			run_server 13337
			puts "done now :)"
		end

		def run_server(port)
			server = TCPServer.new(port)

			#We wait for a client to connect to us.
			puts "Waiting for client"
			socket = server.accept
			puts "Client accepted."

			#The first thing it sends us is the player information:
			ack, data = socket.gets.split(':', 2)
			puts "bot says: #{ack}"

			parse_players(data)

			#We reply that with our cheat flags
			socket.puts(allow_user_control + complete_information)

			#It continues with sending us data.
			parse_unit_types(socket.gets)
			parse_locations(socket.gets)
			parse_map(socket.gets)
			parse_tech_types(socket.gets)
			parse_upgrade_types(socket.gets)

			#clean up after ourselves
			socket.close
			server.close
		end

		def parse_players(data)
			player, enemy = Player.parse(data)
		end

		def parse_unit_types(data)
			unit_types = UnitType.parse(data)
		end

		def parse_locations(data)
			starting_locations = StartingLocation.parse(data)
		end

		def parse_map(data)
			map = Map.parse(data)
		end

		def parse_tech_types(data)
			tech_types = TechType.parse(data)
		end

		def parse_upgrade_types(data)
			upgrade_types = UpgradeType.parse(data)
		end
	end
end

p = RProxyBot::ProxyBot.new
p.run("1","1")

puts p.player.id