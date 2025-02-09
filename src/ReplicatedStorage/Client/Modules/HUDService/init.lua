--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local HUDButtonContainer = require(script.Components.HUDButtonContainer);
local HUDServiceTypes = require(script.types);

local HUDService = {
  actionIDList = {};
  itemButtonProperties = {} :: {HUDServiceTypes.HUDButtonProperties};
  actionButtonProperties = {} :: {HUDServiceTypes.HUDButtonProperties};
}

function HUDService:initialize()

  local player = Players.LocalPlayer;
  local actionButtonContainerGUI = Instance.new("ScreenGui");
  actionButtonContainerGUI.Name = "ActionButtonContainerGUI";
  actionButtonContainerGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
  actionButtonContainerGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
  actionButtonContainerGUI.ResetOnSpawn = false;
  actionButtonContainerGUI.DisplayOrder = 1;
  actionButtonContainerGUI.Enabled = true;
  actionButtonContainerGUI.Parent = player.PlayerGui;

  local itemButtonContainerGUI = actionButtonContainerGUI:Clone();
  itemButtonContainerGUI.Name = "ItemButtonContainerGUI";
  itemButtonContainerGUI.Parent = player.PlayerGui;

  HUDService.actionButtonContainerRoot = ReactRoblox.createRoot(actionButtonContainerGUI);
  HUDService.itemButtonContainerRoot = ReactRoblox.createRoot(itemButtonContainerGUI);

  HUDService.actionButtonContainerGUI = actionButtonContainerGUI;
  HUDService.itemButtonContainerGUI = itemButtonContainerGUI;

  ReplicatedStorage.Shared.Events.RoundEnded.OnClientEvent:Connect(function()

    -- Remove the GUI.
    HUDService.itemButtonContainerRoot:unmount();
    HUDService.actionButtonContainerRoot:unmount();
  
  end);

end;

function HUDService:refreshRoots()

  HUDService.itemButtonContainerRoot:render(
    React.createElement(HUDButtonContainer, {
      type = "Item";
      buttonPropertiesList = HUDService.itemButtonProperties;
    }
  ));

  HUDService.actionButtonContainerRoot:render(
    React.createElement(HUDButtonContainer, {
      type = "Action";
      buttonPropertiesList = HUDService.actionButtonProperties;
    }
  ));

end;

function HUDService:sortActionButtons()

  table.sort(HUDService.actionButtonProperties, function(actionButton1, actionButton2)
    
    local actionButton1Index = table.find(HUDService.actionIDList, actionButton1.key) or math.huge;
    local actionButton2Index = table.find(HUDService.actionIDList, actionButton2.key) or math.huge;
    return actionButton1Index < actionButton2Index;

  end);

end;

function HUDService:addHUDButton(properties: HUDServiceTypes.HUDButtonProperties): ()

  local targetTable = if properties.type == "Action" then HUDService.actionButtonProperties else HUDService.itemButtonProperties;

  table.insert(targetTable, properties);

  if properties.type == "Action" then

    HUDService:sortActionButtons();

  end;

  HUDService:refreshRoots();

end;

function HUDService:removeHUDButton(buttonType: "Action" | "Item", key: string): ()

  local targetTable = if buttonType == "Action" then HUDService.actionButtonProperties else HUDService.itemButtonProperties;

  for index, component in targetTable :: {HUDServiceTypes.HUDButtonProperties} do

    if component.key == key then

      table.remove(targetTable, index);
      break;

    end;

  end;

  if buttonType == "Action" then

    HUDService:sortActionButtons();

  end;

  HUDService:refreshRoots();

end;

function HUDService:setActionIDList(actionIDList: {string}): ()

  HUDService.actionIDList = actionIDList;
  HUDService:refreshRoots();

end;

return HUDService;