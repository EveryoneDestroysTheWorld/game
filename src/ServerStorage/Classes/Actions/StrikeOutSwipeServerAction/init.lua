--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local StrikeOutSwipeClientAction = require(ReplicatedStorage.Client.Classes.Actions.StrikeOutSwipeClientAction);
local IStrikeOutSwipeServerAction = require(ServerStorage.Interfaces.IStrikeOutSwipeServerAction);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);

local chargeSwing = require(script.chargeSwing);
local swingBat = require(script.swingBat);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local createInventoryRemoteEvent = require(ServerStorage.Modules.createInventoryRemoteEvent);

type IStrikeOutSwipeServerAction = IStrikeOutSwipeServerAction.IStrikeOutSwipeServerAction;
type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;

local StrikeOutSwipeServerAction = {
  id = StrikeOutSwipeClientAction.id;
  name = StrikeOutSwipeClientAction.name;
  description = StrikeOutSwipeClientAction.description;
};

function StrikeOutSwipeServerAction.new(contestant: IServerContestant, round: IServerRound): IStrikeOutSwipeServerAction

  local startChargeTimeMilliseconds = 0;
  local maxChargeDurationMilliseconds = 1000;
  local baseDamage = 12;
  local maxBonusDamage = 10;
  local requiredStamina = 5;
  local touchedTimeLimitSeconds = 0.8;

  local function activate(self: IStrikeOutSwipeServerAction, shouldCharge: boolean)

    assert(contestant.attributes.archetypeMode == "Batter", "Contestant must be in batter mode to use this action.");
    assert(contestant.currentStamina >= requiredStamina, "Insufficient stamina.");

    if shouldCharge then

      chargeSwing(self);

    else

      local character = contestant.character;
      local bat = if character then character:FindFirstChild("Bat") else nil;
      assert(bat and bat:IsA("Accessory"), "The contestant's bat is missing.");

      swingBat(self, bat);

    end;

  end;

  local function breakdown(self: IStrikeOutSwipeServerAction)

    if self.remoteFunction then

      self.remoteFunction:Destroy();
  
    end;
  
    if self.remoteEvent then
  
      self.remoteEvent:Destroy();
  
    end;
  
    if contestant.player then
  
      ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
  
    end;

  end;

  local action: IStrikeOutSwipeServerAction = {
    attributes = {};
    contestantID = contestant.id;
    description = StrikeOutSwipeServerAction.description;
    id = StrikeOutSwipeServerAction.id;
    name = StrikeOutSwipeServerAction.name;
    activate = activate;
    breakdown = breakdown;
  }

  local player = contestant.player;
  if player then
  
    local remoteID = `{player.UserId}_{action.id}`;
    action.remoteFunction = createInventoryRemoteFunction(player, "Action", remoteID, function(shouldCharge: boolean)
    
      action:activate(shouldCharge);

    end);

    action.remoteEvent = createInventoryRemoteEvent(player, "Action", remoteID);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  return action;

end;

return StrikeOutSwipeServerAction;