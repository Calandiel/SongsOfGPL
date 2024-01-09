local tabb = require "engine.table"
local economic_effects = require "game.raws.effects.economic"

local tr = {}

---@param realm Realm
function tr.run(realm)
	-- for now ai will be pretty static
	-- it would be nice to tie it to external threats/conditions
	if tabb.size(realm.paying_tribute_to) == 0 then
		economic_effects.set_court_budget(realm, 0.1)
		economic_effects.set_infrastructure_budget(realm, 0.1)
		economic_effects.set_education_budget(realm, 0.3)
		economic_effects.set_military_budget(realm, 0.4)
	else
		economic_effects.set_court_budget(realm, 0.1)
		economic_effects.set_infrastructure_budget(realm, 0.1)
		economic_effects.set_education_budget(realm, 0.3)
		economic_effects.set_military_budget(realm, 0.2)
	end

	realm.budget.treasury_target = 250
end

return tr
