--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
local ClientAction = require(ReplicatedStorage.Client.Classes.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local HUDButtonContainer = require(ReplicatedStorage.Client.ReactComponents.HUDButtonContainer);
local ClientItem = require(ReplicatedStorage.Client.Classes.ClientItem);
local StarterGui = game:GetService("StarterGui");
type ClientArchetype = ClientArchetype.ClientArchetype;
type ClientAction = ClientAction.ClientAction;
type ClientItem = ClientItem.ClientItem;
local RoundResultsWindow = require(script.ReactComponents.RoundResultsWindow);

local initializedArchetype: ClientArchetype = nil;
local initializedActions: {ClientAction} = {};
local initializedItems: {{ClientItem}} = {};

-- Set up the UI.
local player = Players.LocalPlayer;
local actionButtonContainer = Instance.new("ScreenGui");
actionButtonContainer.Name = "ActionButtonContainerGUI";
actionButtonContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
actionButtonContainer.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
actionButtonContainer.ResetOnSpawn = false;
actionButtonContainer.DisplayOrder = 1;
actionButtonContainer.Enabled = true;

local itemButtonContainer = actionButtonContainer:Clone();
itemButtonContainer.Name = "ItemButtonContainerGUI";
local actionButtonContainerRoot = ReactRoblox.createRoot(actionButtonContainer);
local itemButtonContainerRoot = ReactRoblox.createRoot(itemButtonContainer);

local actionButtons = {};
local itemButtons = {};
local function rerenderRoots()

  itemButtonContainer.Parent = player.PlayerGui;
  itemButtonContainerRoot:render(React.createElement(HUDButtonContainer, {type = "Item"}, React.createElement(React.Fragment, {}, itemButtons)));

  actionButtonContainer.Parent = player.PlayerGui;
  actionButtonContainerRoot:render(React.createElement(HUDButtonContainer, {type = "Action"}, actionButtons));

end;

ReplicatedStorage.Client.Functions.AddHUDButton.OnInvoke = function(buttonType: "Action" | "Item", buttonComponent)
  
  assert(buttonType == "Action" or buttonType == "Item");
  assert(buttonComponent);

  table.insert(if buttonType == "Action" then actionButtons else itemButtons, buttonComponent);
  rerenderRoots();

end;

ReplicatedStorage.Client.Functions.DestroyHUDButton.OnInvoke = function(buttonType: "Action" | "Item", key: number)

  local list = if buttonType == "Action" then actionButtons else itemButtons;

  for index, component in list :: {any} do

    if component.key == key then

      table.remove(list, index);
      break;

    end;

  end;

  rerenderRoots();

end;

ReplicatedStorage.Shared.Functions.InitializeArchetype.OnClientInvoke = function(archetypeID: number)

  -- Set up the archetype and actions.
  initializedArchetype = ClientArchetype.get(archetypeID);
  initializedArchetype:initialize();
  print(`Archetype active: {initializedArchetype.name}`);

  for _, actionID in ipairs(initializedArchetype.actionIDs) do

    local action = ClientAction.get(actionID);
    action:initialize();
    table.insert(initializedActions, action);
    print(`Action active: {action.name}`);

  end;

end;

ReplicatedStorage.Shared.Functions.InitializeItem.OnClientInvoke = function(itemID: number, itemNumber: number, ...: any)

  local item = ClientItem.get(itemID);
  item:initialize(itemNumber, ...);
  initializedItems[itemID] = initializedItems[itemID] or {};
  initializedItems[itemID][itemNumber] = item;
  print(`Item active: {item.name}`);

end;

ReplicatedStorage.Shared.Functions.BreakdownItem.OnClientInvoke = function(itemID: number, itemNumber: number)

  initializedItems[itemID][itemNumber]:breakdown();
  initializedItems[itemID][itemNumber] = nil;
  rerenderRoots();

end;

ReplicatedStorage.Shared.Events.RoundEnded.OnClientEvent:Connect(function()

  -- Remove the GUI.
  ReplicatedStorage.Client.Functions.AddHUDButton.OnInvoke = nil;
  itemButtonContainerRoot:unmount();
  actionButtonContainerRoot:unmount();

  -- Breakdown the archetype and actions.
  if initializedArchetype then

    initializedArchetype:breakdown();
    print(`Archetype disabled: {initializedArchetype.name}`);

  end;

  for _, action in initializedActions do

    action:breakdown();
    print(`Action disabled: {action.name}`);

  end;

  for _, itemList in initializedItems do

    for _, item in itemList do

      item:breakdown();
      print(`Item disabled: {item.name}`);
  
    end;

  end;

  -- Add the round results GUI.
  local roundResultsGUI = Instance.new("ScreenGui");
  roundResultsGUI.Name = "RoundResultsGUI";
  roundResultsGUI.Parent = player:WaitForChild("PlayerGui");
  roundResultsGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
  roundResultsGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
  roundResultsGUI.ResetOnSpawn = false;
  roundResultsGUI.DisplayOrder = 1;
  roundResultsGUI.Enabled = true;

  local roundResultsGUIRoot = ReactRoblox.createRoot(roundResultsGUI);
  roundResultsGUIRoot:render(RoundResultsWindow);

end);

while not pcall(function()

  local resetBindable = Instance.new("BindableEvent")
  resetBindable.Event:Connect(function()

    ReplicatedStorage.Shared.Events.ResetButtonPressed:FireServer();

  end)

  -- This will remove the current behavior for when the reset button 
  -- is pressed and just fire resetBindable instead.
  StarterGui:SetCore("ResetButtonCallback", resetBindable);
  
end) do

  task.wait();

end;