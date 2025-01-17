--!strict
local ServerStorage = game:GetService("ServerStorage");

local types = require(script.Parent.Parent.types);

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

function HoldingHeavyItemServerEffect.new(properties: types.HoldingHeavyItemServerEffectConstructorProperties): types.HoldingHeavyItemServerEffect 

  local effect = {
    _lock = {};
    name = HoldingHeavyItemServerEffect.name;
    id = HoldingHeavyItemServerEffect.id;
  };

  return (setmetatable(effect, HoldingHeavyItemServerEffect) :: unknown) :: types.HoldingHeavyItemServerEffect

end;

function HoldingHeavyItemServerEffect.__index:activate(contestant: types.ServerContestant)

  toggleLocks(contestant, self._lock, true);

end;

function HoldingHeavyItemServerEffect.__index:deactivate(contestant: types.ServerContestant)

  toggleLocks(contestant, self._lock, false);

end;

return HoldingHeavyItemServerEffect;