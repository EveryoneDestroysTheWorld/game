--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local ClientAction = require(script.Parent.Parent.ClientAction);
local HUDButton = require(script.Parent.Parent.Parent.ReactComponents.HUDButton);
type ClientAction = ClientAction.ClientAction;
local QuickSelectionMenu = require(ReplicatedStorage.Client.ReactComponents.QuickSelectionMenu);

local DetachLimbAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Detach Limb";
  iconImage = "rbxassetid://17551046771";
  description = "Detach a limb of your choice. It only hurts a little bit.";
};

function DetachLimbAction.new(): ClientAction

  local player = Players.LocalPlayer;
  local remoteName = `{player.UserId}_{DetachLimbAction.id}`;
  local _gui: ScreenGui? = nil;
  local root;

  local function breakdown(self: ClientAction)

    if root then

      root:unmount();

    end;

    if _gui then

      _gui:Destroy();
      _gui = nil;
      
    end;

		ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);
    
  end;

  local function activate(self: ClientAction, limbName: string)

    local gui = _gui or Instance.new("ScreenGui");
    gui.ScreenInsets = Enum.ScreenInsets.None;
    gui.Parent = player.PlayerGui;

    root = ReactRoblox.createRoot(gui);
    root:render(React.createElement(QuickSelectionMenu, {
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

        root:unmount();
        gui:Destroy();
        _gui = nil;
        ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer(selection.key);

      end;
    }));

  end;

  local function initialize(self: ClientAction)
    
  
    ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
      type = "Action";
      key = self.id;
      onActivate = function() self:activate() end;
      shortcutCharacter = "L";
      iconImage = "rbxassetid://17551046771";
    }));
  
    local function toggleGUI(_, inputState: Enum.UserInputState)
  
      if inputState == Enum.UserInputState.Begin then
  
        self:activate()
  
      end;
  
    end;
  
    -- Listen for events.
    ContextActionService:BindActionAtPriority("Detach Limb", toggleGUI, false, 3, Enum.KeyCode.V);

  end;

  local action = ClientAction.new({
    id = DetachLimbAction.id;
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
