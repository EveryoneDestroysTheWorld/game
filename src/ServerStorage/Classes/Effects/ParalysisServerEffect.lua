--!strict
local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Classes.types);

local ParalysisServerEffect = {
  name = "Paralysis";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.ParalysisServerEffect;
}

function ParalysisServerEffect.new(properties: types.ParalysisServerEffectConstructorProperties): types.ParalysisServerEffect

  local effect: types.ParalysisServerEffectProperties = {
    name = ParalysisServerEffect.name;
    id = ParalysisServerEffect.id;
    _contestant = properties.contestant;
    _weight = {
      walkSpeed = 0;
      weight = math.huge;
    }
  };

  return (setmetatable(effect, ParalysisServerEffect) :: unknown) :: types.ParalysisServerEffect

end;

function ParalysisServerEffect.__index:activate(contestant: types.ServerContestant)

  contestant:addWalkSpeedWeight(self._weight);

end;

function ParalysisServerEffect.__index:deactivate(contestant: types.ServerContestant)

  contestant:removeWalkSpeedWeight(self._weight);

end;

return ParalysisServerEffect;