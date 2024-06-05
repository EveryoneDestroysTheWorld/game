--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
type ClientAction = ClientAction.ClientAction;

local DetachLimbAction = {
  ID = 3;
  name = "Detonate Detached Limbs";
  description = "Explodes all detached limbs and regenerates them.";
};

function DetachLimbAction.new(): ClientAction

  local limbSelectorGUI: ScreenGui = nil;
  local selectedLimb: string? = nil;
  local player = Players.LocalPlayer;

  local function breakdown(self: ClientAction)

    

  end;

  local function activate(self: ClientAction)

    if selectedLimb then

      ReplicatedStorage.Shared.Functions.ExecuteAction:InvokeServer(self.ID, "Detach Limb", selectedLimb);

    end;

  end;

  local action = ClientAction.new({
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