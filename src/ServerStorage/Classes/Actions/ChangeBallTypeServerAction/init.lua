--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ChangeBallTypeClientAction = require(ReplicatedStorage.Client.Classes.Actions.ChangeBallTypeClientAction);
local IChangeBallTypeServerAction = require(ServerStorage.Interfaces.IChangeBallTypeServerAction);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local SharedTypes = require(ServerStorage.Modules.SharedTypes);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

type BallType = SharedTypes.BallType;
type IChangeBallTypeServerAction = IChangeBallTypeServerAction.IChangeBallTypeServerAction;
type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;

local ChangeBallTypeServerAction = {
  id = ChangeBallTypeClientAction.id;
  name = ChangeBallTypeClientAction.name;
  description = ChangeBallTypeClientAction.description;
};

function ChangeBallTypeServerAction.new(contestant: IServerContestant, round: IServerRound): IChangeBallTypeServerAction

  local function activate(self: IChangeBallTypeServerAction, ballType: BallType): ()

    local allowedBallTypes: {BallType} = {"Explosive", "Electric", "Poison", "Regular"};
    assert(ballType and typeof(ballType) == "string" and table.find(allowedBallTypes, ballType));
    contestant.attributes.ballType = ballType;
  
  end;

  local function breakdown(self: IChangeBallTypeServerAction)

    if self.remoteFunction then
  
      self.remoteFunction:Destroy();
  
    end;
  
    if contestant.player then
  
      ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
  
    end;
  
  end

  local action: IChangeBallTypeServerAction = {
    id = ChangeBallTypeServerAction.id;
    name = ChangeBallTypeClientAction.name;
    description = ChangeBallTypeServerAction.description;
    contestantID = contestant.id;
    attributes = {};
    activate = activate;
    breakdown = breakdown;
  }

  local player = contestant.player;
  if player then
  
    action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(ballType: BallType)
    
      action:activate(ballType);

    end);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  contestant.attributes.ballType = contestant.attributes.ballType or "Regular";

  return action;

end;

return ChangeBallTypeServerAction;