--!strict
-- Written by Christian Toney (Sudobeast)

local ContextActionService = game:GetService("ContextActionService");
local Action = require(script.Parent.Parent.Action);

local ExplosiveLimbAttack = setmetatable({
  __index = {} :: Action.ActionMethods<ExplosiveLimbAttack>;
}, Action);

type ExplosiveLimbAttackProperties = {
  user: Player?;
  limbSelectorGUI: ScreenGui?;
};

local actionProperties: Action.ActionProperties<ExplosiveLimbAttackProperties> = {
  ID = 1;
  name = "Detach Limb";
  description = "";
};

export type ExplosiveLimbAttack = typeof(setmetatable(Action.new(actionProperties), {__index = ExplosiveLimbAttack.__index}));

function ExplosiveLimbAttack.new(user: Player): ExplosiveLimbAttack

  -- Get everything that comes with being an Action.
  local self = setmetatable(Action.new(actionProperties), ExplosiveLimbAttack.__index );

  -- Set up some unique variables.
  self.user = user;

  -- Return the action.
  return self;

end

function ExplosiveLimbAttack.__index:initialize(): ()
  
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

function ExplosiveLimbAttack.__index:activate(): ()



end;

function ExplosiveLimbAttack.__index:breakdown(): ()

  -- Disconnect events.
  ContextActionService:UnbindAction("Select Limb");
  ContextActionService:UnbindAction("Detach Limb");

  if self.limbSelectorGUI then

    self.limbSelectorGUI:Destroy();

  end;

end;

return ExplosiveLimbAttack;