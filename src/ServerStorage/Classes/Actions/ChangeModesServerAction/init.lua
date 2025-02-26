--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ChangeModesClientAction = require(ReplicatedStorage.Client.Classes.Actions.ChangeModesClientAction);
local SharedTypes = require(ServerStorage.Modules.SharedTypes);
local IChangeModesServerAction = require(ServerStorage.Interfaces.IChangeModesServerAction);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

type IChangeModesServerAction = IChangeModesServerAction.IChangeModesServerAction;
type IServerContestant = IServerContestant.IServerContestant;

local ChangeModesServerAction = {
  id = ChangeModesClientAction.id;
  name = ChangeModesClientAction.name;
  description = ChangeModesClientAction.description;
};

function ChangeModesServerAction.new(contestant: IServerContestant): IChangeModesServerAction

  local function activate(self: IChangeModesServerAction, mode: SharedTypes.BatterUpDemonModes): ()

    local allowedModes: {SharedTypes.BatterUpDemonModes} = {"Pitcher", "Batter"};
    assert(mode and typeof(mode) == "string" and table.find(allowedModes, mode));
    contestant.attributes.archetypeMode = mode;
  
    ServerStorage.Events.ArchetypeModeChanged:Fire(contestant.id);
    
    if contestant.player then
      
      ReplicatedStorage.Shared.Events.ArchetypeModeChanged:FireClient(contestant.player);
  
    end
  
  end;

  local function breakdown(self: IChangeModesServerAction): ()

    if self.remoteFunction then
  
      self.remoteFunction:Destroy();
  
    end;
  
    if contestant.player then
  
      ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
  
    end;
  
  end;

  local action: IChangeModesServerAction = {
    id = ChangeModesServerAction.id;
    name = ChangeModesServerAction.name;
    contestantID = contestant.id;
    description = ChangeModesServerAction.description;
    attributes = {};
    activate = activate;
    breakdown = breakdown;
  };

  local player = contestant.player;
  if player then
  
    action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(mode: SharedTypes.BatterUpDemonModes)
    
      action:activate(mode);

    end);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  return action;

end;

return ChangeModesServerAction;