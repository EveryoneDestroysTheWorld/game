--!strict
-- This module represents an autopilot on the server side.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local types = require(script.Parent.types);

local Autopilot = {} :: types.AutopilotFactory;

-- Returns a ServerItem based on the ID.
function Autopilot.get(autopilotID: string): types.AutopilotClass

  local instance = script.Parent.Effects:FindFirstChild(`{autopilotID}Autopilot`);
  if instance and instance:IsA("ModuleScript") then

    local effect = require(instance) :: any;
    return effect;

  end

  error(`Couldn't find autopilot from ID {autopilotID}.`);

end;

-- Returns a random ServerItem.
function Autopilot.random(): types.AutopilotClass

  local children = script.Parent.Autopilots:GetChildren();
  local selectedChild = children[math.random(1, #children)];
  local autopilot = require(selectedChild) :: types.AutopilotClass;
  return autopilot;

end;

return Autopilot;
