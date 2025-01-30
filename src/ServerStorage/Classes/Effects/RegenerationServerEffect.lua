--!strict

local ServerStorage = game:GetService("ServerStorage");
local HttpService = game:GetService("HttpService");

local types = require(ServerStorage.Modules.types);

local RegenerationServerEffect = {
  name = "Regeneration";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.RegenerationServerEffect;
}

function RegenerationServerEffect.new(properties: types.ServerEffectConstructorProperties): types.RegenerationServerEffect

  local effect: types.RegenerationServerEffectProperties = {
    name = RegenerationServerEffect.name;
    id = RegenerationServerEffect.id;
    uniqueID = HttpService:GenerateGUID(false);
    contestant = properties.contestant;
    rateSeconds = 1;
    maxRegenerations = 3;
    shouldRegenerate = true;
  };

  return (setmetatable(effect, RegenerationServerEffect) :: unknown) :: types.RegenerationServerEffect

end;

function RegenerationServerEffect.__index:activate()
  
  -- Increase the contestant's health.
  for currentRegenerations = 1, self.maxRegenerations do

    if not self.shouldRegenerate then

      return;

    end;

    self.contestant:updateHealth(math.min(self.contestant:getModifiedBaseValue("Health"), self.contestant.currentHealth + 10));

    task.wait(self.rateSeconds);

  end;

end;

function RegenerationServerEffect.__index:breakdown()

  self.shouldRegenerate = false;

end;

return RegenerationServerEffect;