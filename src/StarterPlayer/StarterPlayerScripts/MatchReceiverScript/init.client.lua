--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local player = Players.LocalPlayer;
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
local ClientAction = require(ReplicatedStorage.Client.Classes.ClientAction);
local ClientItem = require(ReplicatedStorage.Client.Classes.ClientItem);
type ClientArchetype = ClientArchetype.ClientArchetype;
type ClientItem = ClientItem.ClientItem;
local RoundResultsWindow = require(script.ReactComponents.RoundResultsWindow);
local types = require(ReplicatedStorage.Client.Modules.types);
local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);

local initializedArchetype: ClientArchetype = nil;
local initializedActions: {types.ClientAction} = {};
local initializedItems: {[string]: {[string]: ClientItem}} = {};

ReplicatedStorage.Shared.Functions.BreakdownAction.OnClientInvoke = function(actionID: string)

  for index, action in initializedActions do

    if action.id == actionID then

      coroutine.wrap(action.breakdown)(action);
      table.remove(initializedActions, index);
      break;

    end;

  end;

end;

ReplicatedStorage.Shared.Functions.InitializeAction.OnClientInvoke = function(actionID: string)

  task.spawn(function()
    
    local action = ClientAction.get(actionID).new();
    table.insert(initializedActions, action);
    print(`Action active: {action.name}`);

  end);

end;

ReplicatedStorage.Shared.Functions.InitializeArchetype.OnClientInvoke = function(archetypeID: string)

  -- Disable the current archetype.
  if initializedArchetype then

    coroutine.wrap(initializedArchetype.breakdown)(initializedArchetype);

  end;

  -- Set up the archetype.
  initializedArchetype = ClientArchetype.get(archetypeID);
  HUDService:setActionIDList(initializedArchetype.actionIDs);
  task.spawn(function()
    
    initializedArchetype:initialize();
    print(`Archetype active: {initializedArchetype.name}`);

  end);

end;

ReplicatedStorage.Shared.Functions.InitializeItem.OnClientInvoke = function(itemID: string?, specificItemID: string?, ...: any)

  assert(itemID);
  assert(specificItemID, `Item {itemID} didn't give an specific ID.`);

  local item = ClientItem.get(itemID);
  print(`Initializing item: {item.name}`);
  item:initialize(specificItemID, ...);
  initializedItems[itemID] = initializedItems[itemID] or {};

  initializedItems[itemID][specificItemID :: string] = item;

end;

ReplicatedStorage.Shared.Functions.BreakdownItem.OnClientInvoke = function(itemID: string?, specificItemID: string?)

  assert(itemID);
  assert(specificItemID, `Item {itemID} didn't give an specific ID.`);

  local item = initializedItems[itemID][specificItemID];
  print(`Breaking down item: {item.name}`);
  item:breakdown();
  initializedItems[itemID][specificItemID] = nil;

end;

ReplicatedStorage.Shared.Events.RoundEnded.OnClientEvent:Connect(function()

  -- Breakdown the archetype and actions.
  if initializedArchetype then

    task.spawn(function()
    
      initializedArchetype:breakdown();
      print(`Archetype disabled: {initializedArchetype.name}`);

    end);

  end;

  for _, action in initializedActions do

    task.spawn(function()

      action:breakdown();
      print(`Action disabled: {action.name}`);

    end)

  end;

  for _, itemList in pairs(initializedItems) do

    for _, item in pairs(itemList) do

      task.spawn(function()
        
        item:breakdown();
        print(`Item disabled: {item.name}`);

      end);
  
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
  roundResultsGUIRoot:render(React.createElement(RoundResultsWindow));

end);

HUDService:initialize();