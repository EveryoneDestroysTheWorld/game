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
  iconImage = "rbxassetid://17551046771";
  description = "Detach a limb of your choice. It only hurts a little bit.";
};

function DetachLimbAction.new(): ClientAction

  local player = Players.LocalPlayer;
  local limbSelectorGUI: ScreenGui;
  local root = nil;

  local function breakdown(self: ClientAction)

    if root then

      root:unmount();

    end;

    if limbSelectorGUI then

      limbSelectorGUI:Destroy();

    end;

  end;

  local function activate(self: ClientAction, limbName: string)

    ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(`{player.UserId}_{DetachLimbAction.ID}`):InvokeServer(limbName);

  end;

  local function initialize(self: ClientAction)

    -- Set up the UI.
    limbSelectorGUI = Instance.new("ScreenGui")
    limbSelectorGUI.Name = "LimbSelectorGUI";
    limbSelectorGUI.Parent = player:WaitForChild("PlayerGui");
    limbSelectorGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
    limbSelectorGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
    limbSelectorGUI.ResetOnSpawn = false;
    limbSelectorGUI.DisplayOrder = 1;
    limbSelectorGUI.Enabled = true;

    local root = ReactRoblox.createRoot(limbSelectorGUI);

    local function activateGUI()

      root:render(React.createElement(LimbSelectionWindow, {
        onSelect = function(limbName) 
          
          self:activate(limbName); 
        
        end;
        onClose = function() root:unmount(); end;
      }));
  
    end;
  
    ReplicatedStorage.Client.Functions.AddActionButton:Invoke(React.createElement(ActionButton, {
      onActivate = function() activateGUI() end;
      shortcutCharacter = "L";
      iconImage = "rbxassetid://17551046771";
    }));
  
    local function toggleGUI(_, inputState: Enum.UserInputState)
  
      if inputState == Enum.UserInputState.Begin then
  
        activateGUI()
  
      elseif inputState == Enum.UserInputState.End then
  
        root:unmount();
  
      end;
  
    end;
  
    -- Listen for events.
    ContextActionService:BindActionAtPriority("Detach Limb", toggleGUI, false, 3, Enum.UserInputType.MouseButton2);

  end;

  local action = ClientAction.new({
    ID = DetachLimbAction.ID;
    name = DetachLimbAction.name;
    iconImage = DetachLimbAction.iconImage;
    description = DetachLimbAction.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });

  return action;

end

return DetachLimbAction;
