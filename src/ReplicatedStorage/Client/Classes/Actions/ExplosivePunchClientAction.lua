--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
type ClientAction = ClientAction.ClientAction;

local ExplosivePunchAction = {
  ID = 1;
  name = "Explosive Punch";
  description = "Land explosive punches to your enemies.";
};

function ExplosivePunchAction.new(): ClientAction

  local function breakdown(self: ClientAction)

    

  end;

  local function activate(self: ClientAction)


  end;

  local action = ClientAction.new({
    ID = ExplosivePunchAction.ID;
    name = ExplosivePunchAction.name;
    description = ExplosivePunchAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  return action;

end

return ExplosivePunchAction;