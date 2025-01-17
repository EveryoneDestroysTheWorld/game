--!strict
local ServerStorage = game:GetService("ServerStorage");

local Cause = require(ServerStorage.Types["Cause.types"]);
type Cause = Cause.Cause;
local ServerEffect = require(script.Parent.Parent.ServerEffect);
type ServerEffect = ServerEffect.ServerEffect;

export type InvincibilityServerEffectProperties = {
  expirationTimeMilliseconds: number;
}

return function(properties: InvincibilityServerEffectProperties): ServerEffect

  local function updateContestantStamina(effect: ServerEffect, newStamina: number, oldStamina: number): number

    return math.max(oldStamina, newStamina);

  end;

  local function updateContestantHealth(effect: ServerEffect, newHealth: number, oldHealth: number): number

    return math.max(oldHealth, newHealth);

  end;

  return {
    name = "Invincibility";
    id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
    updateContestantStamina = updateContestantStamina;
    expirationTimeMilliseconds = properties.expirationTimeMilliseconds,
    updateContestantHealth = updateContestantHealth;
  };

end;