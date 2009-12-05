module RProxyBot
  class BasicAI
    include Constants
    def self.start
      Thread.new do
		a=0 #a houdt nu het punt in het script bij, moet later vervangen worden door status check van verschillende units en gebouwen.
		last_frame = -1
		starcraft = ProxyBot.instance
        player = starcraft.player
        workers = player.workers
		larvae = player.larvae.first
		overlord = player.overlord.first
        center = player.command_centers.first
        minerals = starcraft.units.minerals.sort do |a, b|
          b.distance_to(center) <=> a.distance_to(center)
        end
		
		mineral = minerals.last
		if (mineral.x<center.x)
			poolx = center.x*2-mineral.x
		else
			poolx = center.x-(mineral.x-center.x)+1
		end
		if (mineral.y<center.y)
			pooly = center.y*2-mineral.y
		else
			pooly = center.y-(mineral.y-center.y)+3
		end
		
		larvae.morph_unit(UnitTypes::Drone)
		overlord.right_click( starcraft.map.width-center.x , starcraft.map.height-center.y )
		
        while(true)
			if(last_frame == starcraft.frame)
				sleep(0.01)
			else
				last_frame = starcraft.frame
			    larvae = player.larvae.first
				
				player.workers.each do |worker|
				if worker.order == Orders::PlayerGuard
					worker.right_click_unit(minerals.pop)
					sleep(0.2)
					end
				end				

				player.zerglings.each do |zergling|
				if zergling.order == Orders::PlayerGuard
					zergling.right_click(starcraft.map.width-center.x , starcraft.map.height-center.y)
					sleep(0.2)
					end
				end
				
				if (player.minerals >= 200 && a == 0 )
					a= a+1
					player.workers.first.build(UnitTypes::SpawningPool, poolx, pooly) #moet veranderd worden in een check voor een drone met order::movetominerals
				end
				
				if ( a >=1 && a < 3 && player.minerals >= 50 && player.minerals < 200)
					larvae.morph_unit(UnitTypes::Drone)
					a=a+1
					sleep (0.2)
				end
				
				if ( a >= 3 && player.spawningpool.last.build_timer == 0 && player.minerals >= 50 && player.supply_total > player.supply_used && !player.larvae.empty? == true)
					larvae.morph_unit(UnitTypes::Zergling)
					sleep (0.2)
				end
					
				if (player.minerals  >=  100 && player.supply_total  <=  player.supply_used && !player.larvae.empty? == true && a==3 )
					larvae.morph_unit(UnitTypes::Overlord)
					a=a+1
					sleep(0.2)
				end					

			end
        end
      end
    end
  end
end
