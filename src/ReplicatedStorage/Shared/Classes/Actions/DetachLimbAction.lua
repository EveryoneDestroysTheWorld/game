--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");
local Action = require(script.Parent.Parent.Action);
type Action = Action.Action;

local DetachLimbAction = {
  ID = 1;
  name = "Detach Limb";
  description = "Detach a limb of your choice. It only hurts a little bit.";
};
function DetachLimbAction.new(user: Player): Action

  local limbSelectorGUI: ScreenGui = nil;
  local selectedLimb: string? = nil;

  local function initialize(self: Action)

    if user then

      -- Set up the limb selector UI.
      limbSelectorGUI = Instance.new("ScreenGui");
      limbSelectorGUI.Name = "LimbSelector";
      limbSelectorGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
      limbSelectorGUI.Parent = user.PlayerGui;
      limbSelectorGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
      limbSelectorGUI.ResetOnSpawn = false;
      limbSelectorGUI.DisplayOrder = 1;
      limbSelectorGUI.Enabled = true;
  
      -- Listen for events.
      ContextActionService:BindAction("Select Limb", function() end, false, Enum.KeyCode.J, Enum.KeyCode.K);
      ContextActionService:BindAction("Detach Limb", function() self:activate() end, false, Enum.UserInputType.MouseButton2);
  
    end;

  end;

  local function breakdown(self: Action)

    -- Disconnect events.
    ContextActionService:UnbindAction("Select Limb");
    ContextActionService:UnbindAction("Detach Limb");

    if limbSelectorGUI then

      limbSelectorGUI:Destroy();

    end;

  end;

  local function activate(self: Action)

    if selectedLimb then

      ReplicatedStorage.Shared.Functions.ExecuteAction:InvokeServer(self.ID, "Detach Limb", selectedLimb);

    end;

  end;

  return Action.new({
    ID = DetachLimbAction.ID;
    name = DetachLimbAction.name;
    description = DetachLimbAction.description;
    initialize = initialize;
    activate = activate;
    breakdown = breakdown;
  });

end

return DetachLimbAction;