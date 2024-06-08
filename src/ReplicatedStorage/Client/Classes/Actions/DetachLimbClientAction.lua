--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local ClientAction = require(script.Parent.Parent.ClientAction);
local ActionButton = require(script.Parent.Parent.Parent.ReactComponents.ActionButton);
local LimbSelectionWindow = require(script.Parent.Parent.Parent.ReactComponents.LimbSelectionWindow);
type ClientAction = ClientAction.ClientAction;

local DetachLimbAction = {
  ID = 2;
  name = "Detach Limb";
  description = "Detach a limb of your choice. It only hurts a little bit.";
};

function DetachLimbAction.new(): ClientAction

  -- Set up the UI.
  local player = Players.LocalPlayer;
  local limbSelectorGUI: ScreenGui = Instance.new("ScreenGui");
  limbSelectorGUI.Name = "LimbSelectorGUI";
  limbSelectorGUI.Parent = player:WaitForChild("PlayerGui");
  limbSelectorGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
  limbSelectorGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
  limbSelectorGUI.ResetOnSpawn = false;
  limbSelectorGUI.DisplayOrder = 1;
  limbSelectorGUI.Enabled = true;

  local limbSelection;

  local root = ReactRoblox.createRoot(limbSelectorGUI);
  root:render(React.createElement(LimbSelectionWindow, {
    onSelect = function(newLimbSelection)

      limbSelection = newLimbSelection;

    end;
  }));

  

  local function breakdown(self: ClientAction)

    root:unmount();
    limbSelectorGUI:Destroy();

  end;

  local function activate(self: ClientAction)

    if limbSelection then

      ReplicatedStorage.Shared.Functions:FindFirstChild(`{player.UserId}_{DetachLimbAction.ID}`):InvokeServer();

    end;

  end;

  local action = ClientAction.new({
    ID = DetachLimbAction.ID;
    name = DetachLimbAction.name;
    description = DetachLimbAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  -- Listen for events.
  ContextActionService:BindAction("Select Limb", function() end, false, Enum.KeyCode.J, Enum.KeyCode.K);
  ContextActionService:BindAction("Detach Limb", function() activate(action) end, false, Enum.UserInputType.MouseButton2);

  return action;

end

return DetachLimbAction;
