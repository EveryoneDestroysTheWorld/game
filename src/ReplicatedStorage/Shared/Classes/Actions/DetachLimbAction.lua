--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ContextActionService = game:GetService("ContextActionService");
local Action = require(script.Parent.Parent.Action);

-- This is the class.
local DetachLimbAction = setmetatable({__index = {}}, Action);

local actionProperties: Action.ActionProperties<{
  user: Player?;
  limbSelectorGUI: ScreenGui?;
}> = {
  ID = 1;
  name = "Detach Limb";
  description = "Detach a limb of your choice. It only hurts a little bit.";
};

-- Although it has the same name, this is the object type.
export type DetachLimbAction = typeof(setmetatable(Action.new(actionProperties), {__index = DetachLimbAction.__index}));

-- Returns a new action based on the user.
-- @since v0.1.0
function DetachLimbAction.new(user: Player): DetachLimbAction

  -- Get everything that comes with being an Action.
  local self = setmetatable(Action.new(actionProperties), DetachLimbAction.__index );

  -- Set up some unique variables.
  self.user = user;

  -- Return the action.
  return self;

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