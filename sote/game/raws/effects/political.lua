local ranks = require "game.raws.ranks.character_ranks"
local PoliticalValues = require "game.raws.values.political"

PoliticalEffects = {}

---comment
---@param character Character
function PoliticalEffects.coup(character)
    if character.province == nil then
        return
    end
    local realm = character.province.realm
    if realm == nil then
        return
    end
    if realm.leader == character then
        return
    end
    if realm.capitol ~= character.province then
        return
    end

    if PoliticalValues.power_base(character, realm.capitol) > PoliticalValues.power_base(realm.leader, realm.capitol) then
        PoliticalEffects.transfer_power(character.province.realm, character)
    else
        if WORLD:does_player_see_realm_news(realm) then
            WORLD:emit_notification(character.name .. " failed to overthrow " .. realm.leader.name .. ".")
        end
    end
end


---Transfers control over realm to target
---@param realm Realm
---@param target Character
function PoliticalEffects.transfer_power(realm, target) 
    local depose_message = ""
    if realm.leader ~= nil then
        if WORLD.player_character == realm.leader then
            depose_message = "I am no longer the leader of " .. realm.name .. '.'
        elseif WORLD:does_player_see_realm_news(realm) then
            depose_message = realm.leader.name .. " is no longer the leader of " .. realm.name .. '.'
        end
    end
    local new_leader_message = target.name .. " is now the leader of " .. realm.name .. '.'
    if WORLD.player_character == target then 
        new_leader_message = "I am now the leader of " .. realm.name .. '.'
    end
    if WORLD:does_player_see_realm_news(realm) then
        WORLD:emit_notification(depose_message .. " " .. new_leader_message)
    end

    realm.leader.rank = ranks.NOBLE
    target.rank = ranks.CHIEF
    PoliticalEffects.remove_overseer(realm)

    realm.leader = target
end

---comment
---@param realm Realm
---@param overseer Character
function PoliticalEffects.set_overseer(realm, overseer)
    realm.overseer = overseer

    overseer.popularity = overseer.popularity + 0.5

    if WORLD:does_player_see_realm_news(realm) then
        WORLD:emit_notification(overseer.name .. " is a new overseer of " .. realm.name .. ".")
    end
end

---comment
---@param realm Realm
function PoliticalEffects.remove_overseer(realm)
    local overseer = realm.overseer
    realm.overseer = nil

    if overseer then
        overseer.popularity = overseer.popularity - 0.5
    end

    if overseer and WORLD:does_player_see_realm_news(realm) then
        WORLD:emit_notification(overseer.name .. " is no longer an overseer of " .. realm.name .. ".")
    end
end

---comment
---@param realm Realm
---@param character Character
function PoliticalEffects.set_tribute_collector(realm, character)
    realm.tribute_collectors[character] = character

    character.popularity = character.popularity + 0.1

    if WORLD:does_player_see_realm_news(realm) then
        WORLD:emit_notification(character.name .. " had became a tribute collector.")
    end
end

---comment
---@param realm Realm
---@param character Character
function PoliticalEffects.remove_tribute_collector(realm, character)
    realm.tribute_collectors[character] = nil

    character.popularity = character.popularity - 0.1

    if WORLD:does_player_see_realm_news(realm) then
        WORLD:emit_notification(character.name .. " is no longer a tribute collector.")
    end
end

---Banish the character from the realm
---@param character Character
function PoliticalEffects.banish(character)
    if character.province == nil then
        return
    end
    local realm = character.province.realm
    if realm == nil then
        return
    end
    if realm.leader == character then
        return
    end
end

return PoliticalEffects