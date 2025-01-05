--!strict
-- This module represents a Super Hammer on the client side. It should only be used for item activations.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ClientItem = require(script.Parent.Parent.ClientItem);
type ClientItem = ClientItem.ClientItem;
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);
local ContextActionService = game:GetService("ContextActionService");
local ComboNotification = require(script.ComboNotification);

local SuperHammerClientItem = {
  id = script.Name:sub(1, script.Name:gsub("ClientItem", ""):len());
  name = "Super Hammer";
  description = "Players can use the Giant Hammer to destroy structures and give their enemies a nice facial. Can be thrown, but the player gotta get it back themself!";
  iconImage = "rbxassetid://131350242938144";
};

function SuperHammerClientItem.new(): ClientItem

  local _gui: ScreenGui? = nil;
  local _specificItemID: string?;
  local isActivated: boolean = false;
  local didServerSwing = false;

  local function toggleHotkeys(self: ClientItem)

    local function handleHotkeyActivation(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)

      if inputState == Enum.UserInputState.Begin or (inputState == Enum.UserInputState.End and not didServerSwing) then

        local didActivate, errorMessage = pcall(function()
        
          self:activate();

        end);
        
        if not didActivate then

          didServerSwing = inputState == Enum.UserInputState.Begin;
          error(errorMessage, 0);

        end;

      end;

      didServerSwing = false;

    end;

    ContextActionService:BindActionAtPriority("ActivateSuperHammer", handleHotkeyActivation, false, 1, Enum.UserInputType.MouseButton1);

  end

  local function breakdown(self: ClientItem)

    assert(_specificItemID);
    ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Item", _specificItemID);
    ContextActionService:UnbindAction("ActivateSuperHammer");
    _specificItemID = nil;

  end;

  local function activate(self: ClientItem): ()

    assert(_specificItemID);
    ReplicatedStorage.Shared.Functions.ItemFunctions:FindFirstChild(_specificItemID):InvokeServer(isActivated);

  end;

  local function initialize(self: ClientItem, specificItemID: string)

    _specificItemID = specificItemID;
    local hudButton = React.createElement(HUDButton, {
      type = "Item";
      key = specificItemID;
      onActivate = function() 
        
        toggleHotkeys(self);
        self:activate();
      
      end;
      iconImage = "rbxassetid://17551046771";
    });
    
    ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Item", hudButton);

    local event = ReplicatedStorage.Shared.Events.ItemEvents:FindFirstChild(_specificItemID);
    if event and event:IsA("RemoteEvent") then

      event.OnClientEvent:Connect(function(eventType: string)
      
        didServerSwing = eventType == "Swing";

      end);

      local gui = Instance.new("ScreenGui")
      gui.Name = "ComboNotificationGUI";
      gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui");
      gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
      gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets;
      gui.ResetOnSpawn = false;
      gui.DisplayOrder = 1;
      gui.Enabled = true;
      _gui = gui;

      local root = ReactRoblox.createRoot(gui);
      root:render(React.createElement(ComboNotification, {event = event}));

    end;

  end;

  return ClientItem.new({
    id = SuperHammerClientItem.id;
    iconImage = SuperHammerClientItem.iconImage;
    name = SuperHammerClientItem.name;
    description = SuperHammerClientItem.description;
    breakdown = breakdown;
    activate = activate;
    initialize = initialize;
  });

end;

return SuperHammerClientItem;