local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
local ClientAction = require(ReplicatedStorage.Client.Classes.ClientAction);
type ClientArchetype = ClientArchetype.ClientArchetype;
type ClientAction = ClientAction.ClientAction;

local currentArchetype: ClientArchetype = nil;
local currentActions: {ClientAction} = {};

ReplicatedStorage.Shared.Functions.InitializeInventory.OnClientInvoke = function(archetypeID: number)

  -- Set up the archetype and actions.
  currentArchetype = ClientArchetype.get(archetypeID);
  print(`Archetype active: {currentArchetype.name}`);

  for _, actionID in ipairs(currentArchetype.actionIDs) do

    local action = ClientAction.get(actionID);
    print(`Action active: {action.name}`);
    table.insert(currentActions, action);

  end;

end;

ReplicatedStorage.Shared.Events.RoundEnded.OnClientEvent:Connect(function()

  -- Breakdown the archetype and actions.
  if currentArchetype then

    currentArchetype:breakdown();
    print(`Archetype disabled: {currentArchetype.name}`);

  end;

  for _, action in ipairs(currentActions) do

    action:breakdown();
    print(`Action disabled: {action.name}`);

  end;

end);