--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerAction = require(ServerStorage.Classes.ServerAction);
local types = require(ServerStorage.Modules.types);

local function initializeArchetypeActions(actionIDs: {string}, contestant: types.ServerContestant): {types.ServerAction}

  local actions = {};

  for _, actionID in actionIDs do

    local action = ServerAction.get(actionID).new({
      contestant = contestant;
    });

    table.insert(actions, action);

  end;

  return actions;

end;

return initializeArchetypeActions;