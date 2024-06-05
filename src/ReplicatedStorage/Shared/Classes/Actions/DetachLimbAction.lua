--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");
local Action = require(script.Parent.Parent.Action);

-- This is the class.
local DetachLimbAction = {
  __index = {
    ID = 1;
    name = "Detach Limb";
    description = "Detach a limb of your choice. It only hurts a little bit.";
  } :: Action.ActionProperties & DetachLimbActionProperties & Action.ActionMethods<DetachLimbAction>; -- Keeps IntelliSense working in the methods.
};

export type DetachLimbActionProperties = {
  limbSelectorGUI: ScreenGui?;
  selectedLimb: string?;
  user: Player?;
};

-- Although it has the same name, this is the object type.
export type DetachLimbAction = Action.Action & typeof(DetachLimbAction.__index);

-- Returns a new action based on the user.
-- @since v0.1.0
function DetachLimbAction.new(user: Player): DetachLimbAction

  -- Get everything that comes with being an Action.
  local properties = DetachLimbAction.__index;
  properties.user = user;
  return setmetatable(DetachLimbAction.__index, {__index = Action.new(properties)}) :: DetachLimbAction;

end

-- @since v0.1.0
function DetachLimbAction.__index:initialize(): ()

  if self.user then

    -- Set up the limb selector UI.
    local limbSelectorGUI = Instance.new("ScreenGui")
    limbSelectorGUI.Name = "LimbSelector";
    limbSelectorGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
    limbSelectorGUI.Parent = self.user.PlayerGui;
    limbSelectorGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
    limbSelectorGUI.ResetOnSpawn = false;
    limbSelectorGUI.DisplayOrder = 1;
    limbSelectorGUI.Enabled = true;
    self.limbSelectorGUI = limbSelectorGUI;

    -- Listen for events.
    ContextActionService:BindAction("Select Limb", function() end, false, Enum.KeyCode.J, Enum.KeyCode.K);
    ContextActionService:BindAction("Detach Limb", function() self:activate() end, false, Enum.UserInputType.MouseButton2);

  end;

end;

-- @since v0.1.0
function DetachLimbAction.__index:activate(): ()

  ReplicatedStorage.Shared.Functions.ExecuteAction:InvokeServer(self.ID, "Detach Limb", self.selectedLimb);

end;

-- @since v0.1.0
function DetachLimbAction.__index:breakdown(): ()

  -- Disconnect events.
  ContextActionService:UnbindAction("Select Limb");
  ContextActionService:UnbindAction("Detach Limb");

  if self.limbSelectorGUI then

    self.limbSelectorGUI:Destroy();

  end;

end;

return DetachLimbAction;