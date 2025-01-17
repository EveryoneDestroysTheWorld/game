--!strict
local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Classes.types);

local InvincibilityServerEffect = {
  name = "Invincibility";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.InvincibilityServerEffect;
}

function InvincibilityServerEffect.new(properties: types.InvinicbilityServerEffectConstructorProperties): types.InvincibilityServerEffect

  local effect = {
    expirationTimeMilliseconds = properties.expirationTimeMilliseconds;
    name = InvincibilityServerEffect.name;
    id = InvincibilityServerEffect.id;
  };

  return (setmetatable(effect, InvincibilityServerEffect) :: unknown) :: types.InvincibilityServerEffect

end;

function InvincibilityServerEffect.__index:updateContestantStamina(newStamina: number, oldStamina: number): number

  return math.max(oldStamina, newStamina);

end;

function InvincibilityServerEffect.__index:updateContestantHealth(newHealth: number, oldHealth: number): number

  return math.max(oldHealth, newHealth);

end;

return InvincibilityServerEffect;