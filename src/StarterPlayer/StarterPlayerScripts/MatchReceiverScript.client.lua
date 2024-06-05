local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Archetype = require(ReplicatedStorage.Client.Classes.Archetype);
local Action = require(ReplicatedStorage.Client.Classes.Action);
type Archetype = Archetype.Archetype;
type Action = Action.Action;

local currentArchetype: Archetype = nil;
local currentActions: {Action} = {};

ReplicatedStorage.Shared.Functions.InitializeInventory.OnClientInvoke = function(archetypeID: number)

  -- Set up the archetype and actions.
  currentArchetype = Archetype.get(archetypeID);
  print(`Archetype active: {currentArchetype.name}`);

  for _, actionID in ipairs(currentArchetype.actionIDs) do

    local action = Action.get(actionID);
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