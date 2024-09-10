--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
local ClientAction = require(ReplicatedStorage.Client.Classes.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local ActionButtonContainer = require(ReplicatedStorage.Client.ReactComponents.ActionButtonContainer);
local StarterGui = game:GetService("StarterGui");
type ClientArchetype = ClientArchetype.ClientArchetype;
type ClientAction = ClientAction.ClientAction;
local RoundResultsWindow = require(script.ReactComponents.RoundResultsWindow);

local currentArchetype: ClientArchetype = nil;
local currentActions: {ClientAction} = {};

-- Set up the UI.
local player = Players.LocalPlayer;
local actionButtonContainer = Instance.new("ScreenGui");
actionButtonContainer.Name = "ActionButtonContainerGUI";
actionButtonContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
actionButtonContainer.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
actionButtonContainer.ResetOnSpawn = false;
actionButtonContainer.DisplayOrder = 1;
actionButtonContainer.Enabled = true;

local root = ReactRoblox.createRoot(actionButtonContainer);

ReplicatedStorage.Shared.Functions.InitializeInventory.OnClientInvoke = function(archetypeID: number)

  -- Set up the action container GUI.
  actionButtonContainer.Parent = player:WaitForChild("PlayerGui");
  root:render(React.createElement(ActionButtonContainer));

  -- Set up the archetype and actions.
  currentArchetype = ClientArchetype.get(archetypeID);
  currentArchetype:initialize();
  print(`Archetype active: {currentArchetype.name}`);

  for _, actionID in ipairs(currentArchetype.actionIDs) do

    local action = ClientAction.get(actionID);
    action:initialize();
    print(`Action active: {action.name}`);
    table.insert(currentActions, action);

  end;

end;

ReplicatedStorage.Shared.Events.RoundEnded.OnClientEvent:Connect(function()

  -- Remove the GUI.
  actionButtonContainer:Destroy();

  -- Breakdown the archetype and actions.
  if currentArchetype then

    currentArchetype:breakdown();
    print(`Archetype disabled: {currentArchetype.name}`);

  end;

  for _, action in ipairs(currentActions) do

    action:breakdown();
    print(`Action disabled: {action.name}`);

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