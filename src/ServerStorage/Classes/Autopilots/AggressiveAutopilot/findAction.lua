--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local findInTable = require(ReplicatedStorage.Shared.Modules.findInTable);

local function findAction(actionList: {types.ServerAction}, actionID: string)

  return findInTable(actionList, function(action)
        
    return action.id == actionID;

  end)

end;

return findAction;