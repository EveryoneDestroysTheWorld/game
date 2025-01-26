--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ServerAction = require(script.Parent.Parent.ServerAction);
local ChangeBallTypeClientAction = require(ReplicatedStorage.Client.Classes.Actions.ChangeBallTypeClientAction);
local types = require(ServerStorage.Classes.types);

local ChangeBallTypeServerAction = {
  id = ChangeBallTypeClientAction.id;
  name = ChangeBallTypeClientAction.name;
  description = ChangeBallTypeClientAction.description;
};

function ChangeBallTypeServerAction.new(): types.ServerAction

  local contestant: types.ServerContestant = nil;
  local function activate(self: types.ServerAction)

    -- TODO: Change ball type.

  end;

  local remoteFunction: RemoteFunction?;
  local function breakdown()

    if remoteFunction then

      remoteFunction:Destroy();

    end;

  end;

  local function initialize(self: types.ServerAction, newContestant: types.ServerContestant)

    contestant = newContestant;

    if contestant.player then
    
      local actionRemoteFunction = Instance.new("RemoteFunction");
      actionRemoteFunction.Name = `{contestant.player.UserId}_{self.id}`;
      actionRemoteFunction.OnServerInvoke = function(player)
  
        if player == contestant.player then
  
          self:activate();
  
        else
  
          -- That's weird.
          error("Unauthorized.");
  
        end
  
      end;
      actionRemoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
      remoteFunction = actionRemoteFunction;
  
    end;

  end;

  return ServerAction.new({
    name = ChangeBallTypeServerAction.name;
    id = ChangeBallTypeServerAction.id;
    description = ChangeBallTypeServerAction.description;
    breakdown = breakdown;
    activate = activate;
    initialize = initialize;
  });

end;

return ChangeBallTypeServerAction;