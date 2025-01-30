--!strict
local ServerStorage = game:GetService("ServerStorage");
local HttpService = game:GetService("HttpService");

local types = require(ServerStorage.Modules.types);

local InvincibilityServerEffect = {
  name = "Invincibility";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.InvincibilityServerEffect;
}

function InvincibilityServerEffect.new(properties: types.ServerEffectConstructorProperties): types.InvincibilityServerEffect

  local effect = {
    name = InvincibilityServerEffect.name;
    id = InvincibilityServerEffect.id;
    uniqueID = HttpService:GenerateGUID(false);
  };

  return (setmetatable(effect, InvincibilityServerEffect) :: unknown) :: types.InvincibilityServerEffect

end;

function InvincibilityServerEffect.__index:activate()

end;

function InvincibilityServerEffect.__index:breakdown()

end;

function InvincibilityServerEffect.__index:updateContestantStamina(newStamina: number, oldStamina: number): number

  return math.max(oldStamina, newStamina);

end;

function InvincibilityServerEffect.__index:updateContestantHealth(newHealth: number, oldHealth: number): number

  return math.max(oldHealth, newHealth);

end;

return InvincibilityServerEffect;