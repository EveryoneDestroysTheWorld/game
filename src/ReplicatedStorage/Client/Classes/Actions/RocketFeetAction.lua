--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local Action = require(script.Parent.Parent.Action);
type Action = Action.Action;

local DetachLimbAction = {
  ID = 4;
  name = "Rocket Feet";
  description = "Fly, touch the sky!";
};

function DetachLimbAction.new(): Action

  local function breakdown(self: Action)

    

  end;

  local function activate(self: Action)

    ReplicatedStorage.Shared.Functions.ExecuteAction:InvokeServer(self.ID, script.Parent.Name);

  end;

  local action = Action.new({
    ID = DetachLimbAction.ID;
    name = DetachLimbAction.name;
    description = DetachLimbAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  return action;

end

return DetachLimbAction;