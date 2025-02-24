--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);

local QuickSelectionMenu = require(ReplicatedStorage.Client.ReactComponents.QuickSelectionMenu);

local DetachLimbClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Detach Limb";
  iconImage = "rbxassetid://17551046771";
  description = "Detach a limb of your choice. It only hurts a little bit.";
};

local player = Players.LocalPlayer;

function DetachLimbClientAction.new(): SharedTypes.DetachLimbClientAction

  local remoteName = `{player.UserId}_{DetachLimbClientAction.id}`;
  local action: SharedTypes.DetachLimbClientAction = {
    id = DetachLimbClientAction.id;
    name = DetachLimbClientAction.name;
    iconImage = DetachLimbClientAction.iconImage;
    description = DetachLimbClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    attributes = {};
    activate = function(self: SharedTypes.DetachLimbClientAction)

      local gui = self.attributes.gui or Instance.new("ScreenGui");
      gui.ScreenInsets = Enum.ScreenInsets.None;
      gui.Parent = Players.LocalPlayer.PlayerGui;
      self.attributes.gui = gui;
    
      local reactRoot = ReactRoblox.createRoot(gui);
      reactRoot:render(React.createElement(QuickSelectionMenu, {
        options = {
          {
            key = "Head";
            labelText = "Head";
            iconImage = "rbxassetid://136558858062155"
          };
          {
            key = "LeftArm";
            labelText = "Left Arm";
            iconImage = "rbxassetid://136558858062155"
          };
          {
            key = "Torso";
            labelText = "Torso";
            iconImage = "rbxassetid://136558858062155"
          };
          {
            key = "RightArm";
            labelText = "Right Arm";
            iconImage = "rbxassetid://136558858062155"
          };
          {
            key = "LeftLeg";
            labelText = "Left Leg";
            iconImage = "rbxassetid://136558858062155"
          };
          {
            key = "RightLeg";
            labelText = "Right Leg";
            iconImage = "rbxassetid://136558858062155"
          };
        };
        onSelectionConfirmed = function(selection)
    
          reactRoot:unmount();
          gui:Destroy();
          self.attributes.gui = nil;
          self.remoteFunction:InvokeServer(selection.key);
    
        end;
      }));
    
    end;
    breakdown = function(self: SharedTypes.DetachLimbClientAction)

      if self.attributes.gui then
    
        self.attributes.gui:Destroy();
        self.attributes.gui = nil;
        
      end;
    
      ContextActionService:UnbindAction("ActivateDetachLimbAction");
      HUDService:removeHUDButton("Action", self.id);
    
    end;
  };

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    onActivate = function() action:activate() end;
    shortcutCharacter = "L";
    iconImage = "rbxassetid://17551046771";
  });

  local function toggleGUI(_, inputState: Enum.UserInputState)

    if inputState == Enum.UserInputState.Begin then

      action:activate()

    end;

  end;

  -- Listen for events.
  ContextActionService:BindActionAtPriority("ActivateDetachLimbAction", toggleGUI, false, 3, Enum.KeyCode.C);

  return action;

end

return DetachLimbClientAction;
