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

  local limbSelectorGUI: ScreenGui = nil;
  local selectedLimb: string? = nil;
  local player = Players.LocalPlayer;

  local function breakdown(self: Action)

    

  end;

  local function activate(self: Action)

    if selectedLimb then

      ReplicatedStorage.Shared.Functions.ExecuteAction:InvokeServer(self.ID, "Detach Limb", selectedLimb);

    end;

  end;

  local action = Action.new({
    ID = DetachLimbAction.ID;
    name = DetachLimbAction.name;
    description = DetachLimbAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  -- Set up the limb selector UI.
  limbSelectorGUI = Instance.new("ScreenGui");
  limbSelectorGUI.Name = "LimbSelector";
  limbSelectorGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
  limbSelectorGUI.Parent = player.PlayerGui;
  limbSelectorGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
  limbSelectorGUI.ResetOnSpawn = false;
  limbSelectorGUI.DisplayOrder = 1;
  limbSelectorGUI.Enabled = true;

  -- Listen for events.
  ContextActionService:BindAction("Select Limb", function() end, false, Enum.KeyCode.J, Enum.KeyCode.K);
  ContextActionService:BindAction("Detach Limb", function() activate(action) end, false, Enum.UserInputType.MouseButton2);

  return action;

end

return DetachLimbAction;