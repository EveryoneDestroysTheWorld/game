--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local Action = require(script.Parent.Parent.Action);
type Action = Action.Action;

local ExplosivePunchAction = {
  ID = 1;
  name = "Explosive Punch";
  description = "Land explosive punches to your enemies.";
};

function ExplosivePunchAction.new(): Action

  local function breakdown(self: Action)

    

  end;

  local function activate(self: Action)


  end;

  local action = Action.new({
    ID = ExplosivePunchAction.ID;
    name = ExplosivePunchAction.name;
    description = ExplosivePunchAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  return action;

end

return ExplosivePunchAction;