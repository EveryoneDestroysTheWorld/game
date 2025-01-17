--!strict
local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Classes.types);

local StaminaRecoverySuppressionServerEffect = {
  name = "Stamina recovery suppression";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.InvincibilityServerEffect;
}

function StaminaRecoverySuppressionServerEffect.new(properties: types.InvinicbilityServerEffectConstructorProperties): types.InvincibilityServerEffect

  local effect = {
    expirationTimeMilliseconds = properties.expirationTimeMilliseconds;
    name = StaminaRecoverySuppressionServerEffect.name;
    id = StaminaRecoverySuppressionServerEffect.id;
  };

  return (setmetatable(effect, StaminaRecoverySuppressionServerEffect) :: unknown) :: types.InvincibilityServerEffect

end;

function StaminaRecoverySuppressionServerEffect.__index:updateContestantStamina(newStamina: number, oldStamina: number): number

  return oldStamina;

end;

return StaminaRecoverySuppressionServerEffect;