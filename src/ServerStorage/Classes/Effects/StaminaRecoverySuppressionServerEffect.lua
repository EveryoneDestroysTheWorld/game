--!strict
local ServerStorage = game:GetService("ServerStorage");
local HttpService = game:GetService("HttpService");

local types = require(ServerStorage.Modules.types);

local StaminaRecoverySuppressionServerEffect = {
  name = "Stamina recovery suppression";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.InvincibilityServerEffect;
}

function StaminaRecoverySuppressionServerEffect.new(properties: types.ServerEffectConstructorProperties): types.InvincibilityServerEffect

  local effect = {
    name = StaminaRecoverySuppressionServerEffect.name;
    id = StaminaRecoverySuppressionServerEffect.id;
    uniqueID = HttpService:GenerateGUID(false);
  };

  return (setmetatable(effect, StaminaRecoverySuppressionServerEffect) :: unknown) :: types.InvincibilityServerEffect

end;

function StaminaRecoverySuppressionServerEffect.__index:activate()

end;

function StaminaRecoverySuppressionServerEffect.__index:breakdown()

end;

function StaminaRecoverySuppressionServerEffect.__index:updateContestantStamina(newStamina: number, oldStamina: number): number

  return oldStamina;

end;

return StaminaRecoverySuppressionServerEffect;