local tabb = require "engine.table"
local ll = {}

function ll.load()
	local Event = require "game.raws.events"

	-- For automatic events:
	-- 1. Roll against << base_probability >>
	-- 2. Check << trigger >>
	-- 3. Apply << on_trigger >>
	-- ...
	-- For events in the queue
	-- 1. Check if it applies to the player
	-- 2. If it doesn't, get the option with the highest ai score
	-- 3. Apply

	print("lack needs events")
	require "game.raws.events.lack-events" ()

	print("war events")
	require "game.raws.events.war-events" ()

	print("outlaw events")
	require "game.raws.events.outlaw-events" ()

	print("raid events")
	require "game.raws.events.raid-events" ()

	print("misc. events")
	local gift_cost_per_pop = require "game.gifting".gift_cost_per_pop
	Event:new {
		name = "people-unhappy",
		event_text = function(self, realm, associated_data)
			local name = associated_data.name
			return "Our kinsmen are unhappy with our rule. One of most prominent naysayers, " ..
				name ..
				", brought forth his friends and family to publicly demand we take action. 'You have failed us and our children! Our enemies mock us, our ancestors scorn us. If nothing changes soon, we'll pick up our belongings and leave.'"
		end,
		event_background_path = "data/gfx/backgrounds/background.png",
		automatic = true,
		base_probability = 1 / 24,
		trigger = function(self, realm)
			---@type Realm
			local realm = realm
			return realm.capitol.mood < -5
		end,
		on_trigger = function(self, realm)
			---@type Realm
			local realm = realm
			WORLD:emit_event(self, realm, {
				name = realm.primary_culture.language:get_random_name()
			})
		end,
		options = function(self, realm, associated_data)
			---@type Realm
			local realm = realm
			local pop = realm.capitol:population()
			local name = associated_data.name
			return {
				{
					text = "Do nothing",
					tooltip = "Sometimes it's better to let your problems fix themselves.",
					viable = function()
						return true
					end,
					outcome = function()
						if realm == WORLD.player_realm then
							WORLD:emit_notification("People complained and grumbled but eventually left and returned to their homes.")
						end
						realm.capitol.mood = realm.capitol.mood - 2
					end,
					ai_preference = function()
						return 0.25
					end
				},
				{
					text = "Convince them to stay",
					tooltip = "Things aren't so bad. They just need some help seeing that.",
					viable = function()
						return true
					end,
					outcome = function()
						local flip = love.math.random() < 0.25
						if flip then
							if realm == WORLD.player_realm then
								WORLD:emit_notification("After a lengthy discussion " ..
									name .. " was convinced of your ability to rule. People praised your wisdom and were brought closer together.")
							end
							realm.capitol.mood = realm.capitol.mood + 3
						else
							if realm == WORLD.player_realm then
								WORLD:emit_notification(name ..
									" wasn't very impressed with your arguments. He and his family stayed but kept complaining and soon even more people were unhappy with our rule.")
							end
							realm.capitol.mood = realm.capitol.mood - 3
						end
					end,
					ai_preference = function()
						return 0.25
					end
				}, {
					text = "Tell them to leave",
					tooltip = "If they don't want to be here anymore, there's no reason to keep them.",
					viable = function()
						return true
					end,
					outcome = function()
						local flip = love.math.random() < 0.5
						if flip then
							if realm == WORLD.player_realm then
								WORLD:emit_notification(name ..
									" grumbled but didn't do anything. Eventually, people stopped listening to his constant complaints.")
							end
							realm.capitol.mood = realm.capitol.mood + 1
						else
							if realm == WORLD.player_realm then
								WORLD:emit_notification(name ..
									" and his family left. Others soon followed and the ones who remained were upset by our decision.")
							end
							realm.capitol.mood = realm.capitol.mood - 1
							-- We should move a bunch of pops to the outlaw tab
							local to_leave = math.floor(pop * love.math.random() * 0.15)
							for i = 1, to_leave do
								local to_outlaw = tabb.nth(realm.capitol.all_pops, love.math.random(tabb.size(realm.capitol.all_pops)))
								realm.capitol:outlaw_pop(to_outlaw)
							end
						end
					end,
					ai_preference = function()
						return 0.1
					end
				},
				{
					text = "Remind them of their duty towards their kinsmen",
					tooltip = "Things aren't that bad.",
					viable = function()
						return true
					end,
					outcome = function()
						if realm == WORLD.player_realm then
							WORLD:emit_notification("People complained and grumbled but eventually left and returned to their homes.")
						end
						realm.capitol.mood = realm.capitol.mood - 1
					end,
					ai_preference = function()
						return 0.25
					end
				},
				{
					text = "Gift his family",
					tooltip = "When flattery fails, bribery may work",
					viable = function()
						return 5 * gift_cost_per_pop < realm.treasury
					end,
					outcome = function()
						realm.treasury = realm.treasury - 5 * gift_cost_per_pop
						local flip = love.math.random() < 0.75
						if flip then
							if realm == WORLD.player_realm then
								WORLD:emit_notification("Swayed by gifts, " ..
									name .. " was satisfied but people complained that we're choosing favourites.")
							end
							realm.capitol.mood = realm.capitol.mood - 1
						else
							if realm == WORLD.player_realm then
								WORLD:emit_notification("Swayed by gifts, " ..
									name .. " was satisfied and soon everyone forgot about the whole affair.")
							end
							realm.capitol.mood = realm.capitol.mood + 1
						end
					end,
					ai_preference = function()
						return 1
					end
				},
				{
					text = "Gift everyone",
					tooltip = "When flattery fails, bribery may work",
					viable = function()
						return pop * gift_cost_per_pop < realm.treasury
					end,
					outcome = function()
						realm.treasury = realm.treasury - pop * gift_cost_per_pop
						local flip = love.math.random() < 0.75
						if flip then
							if realm == WORLD.player_realm then
								WORLD:emit_notification("Swayed by gifts, " ..
									name .. " was satisfied and soon everyone forgot about the whole affair.")
							end
							realm.capitol.mood = realm.capitol.mood + 2
						end
					end,
					ai_preference = function()
						return 1
					end
				},
				{
					text = "Promise to work on changing things",
					tooltip = "Tooltip",
					viable = function()
						return pop * gift_cost_per_pop < realm.resources[WORLD.trade_goods_by_name['food']]
					end,
					outcome = function()
						local flip = love.math.random() * realm:get_speechcraft_efficiency() > 0.5
						if flip then
							if realm == WORLD.player_realm then
								WORLD:emit_notification("People were convinced of our words and returned to their daily lives with new-found energy")
							end
							realm.capitol.mood = realm.capitol.mood + 1
						else
							if realm == WORLD.player_realm then
								WORLD:emit_notification("People were unhappy and didn't believe our words but returned to their daily lives for now.")
							end
							realm.capitol.mood = realm.capitol.mood - 2
						end
					end,
					ai_preference = function()
						return 1
					end
				}
			}
		end
	}
end

return ll
