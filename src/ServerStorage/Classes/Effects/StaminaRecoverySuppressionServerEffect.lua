--!strict
local ServerStorage = game:GetService("ServerStorage");

local Cause = require(ServerStorage.Types["Cause.types"]);
type Cause = Cause.Cause;
local ServerEffect = require(script.Parent.Parent.ServerEffect);
type ServerEffect = ServerEffect.ServerEffect;

return function(): ServerEffect

  local function updateContestantStamina(effect: ServerEffect, newStamina: number, oldStamina: number): number

    return oldStamina;

  end;

  return {
    name = "Stamina recovery suppression";
    id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
    updateContestantStamina = updateContestantStamina;
  };

end;