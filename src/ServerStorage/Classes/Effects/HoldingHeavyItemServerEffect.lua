--!strict

local ServerStorage = game:GetService("ServerStorage");
local HttpService = game:GetService("HttpService");

local types = require(ServerStorage.Modules.types);

local HoldingHeavyItemServerEffect = {
  name = "Holding heavy item";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.HoldingHeavyItemServerEffect;
}

local function toggleLocks(contestant: types.ServerContestant, lock, shouldLock: boolean)

  ServerStorage.Functions.ToggleActionLock:Invoke(contestant.id, lock, shouldLock);
  ServerStorage.Functions.ToggleArchetypeLock:Invoke(contestant.id, lock, shouldLock);
  ServerStorage.Functions.ToggleItemLock:Invoke(contestant.id, lock, shouldLock);

end;

function HoldingHeavyItemServerEffect.new(properties: types.ServerEffectConstructorProperties): types.HoldingHeavyItemServerEffect 

  local effect = {
    contestant = properties.contestant;
    uniqueID = HttpService:GenerateGUID(false);
    _lock = {};
    name = HoldingHeavyItemServerEffect.name;
    id = HoldingHeavyItemServerEffect.id;
  };

  return (setmetatable(effect, HoldingHeavyItemServerEffect) :: unknown) :: types.HoldingHeavyItemServerEffect

end;

function HoldingHeavyItemServerEffect.__index:activate()

  toggleLocks(self.contestant, self.lock, true);

end;

function HoldingHeavyItemServerEffect.__index:breakdown()

  toggleLocks(self.contestant, self.lock, false);

end;

return HoldingHeavyItemServerEffect;