--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local StrikeOutSwipeClientAction = require(ReplicatedStorage.Client.Classes.Actions.StrikeOutSwipeClientAction);
local types = require(ServerStorage.Modules.types);

local chargeSwing = require(script.chargeSwing);
local swingBat = require(script.swingBat);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local createInventoryRemoteEvent = require(ServerStorage.Modules.createInventoryRemoteEvent);

local StrikeOutSwipeServerAction = {
  id = StrikeOutSwipeClientAction.id;
  name = StrikeOutSwipeClientAction.name;
  description = StrikeOutSwipeClientAction.description;
  __index = {
    name = StrikeOutSwipeClientAction.name;
    id = StrikeOutSwipeClientAction.id;
    description = StrikeOutSwipeClientAction.description;
  } :: types.StrikeOutSwipeServerAction;
};

function StrikeOutSwipeServerAction.new(properties: types.ServerActionConstructorProperties): types.StrikeOutSwipeServerAction

  local action = (setmetatable({}, StrikeOutSwipeServerAction) :: any) :: types.StrikeOutSwipeServerAction;
  action.contestant = properties.contestant;
  action.startChargeTimeMilliseconds = 0;
  action.maxChargeDurationMilliseconds = 1000;
  action.baseDamage = 12;
  action.maxBonusDamage = 10;
  action.requiredStamina = 5;
  action.touchedTimeLimitSeconds = 0.8;

  local player = action.contestant.player;
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

function StrikeOutSwipeServerAction.__index:activate(shouldCharge: boolean): ()

  assert(self.contestant.attributes.archetypeMode == "Batter", "Contestant must be in batter mode to use this action.");
  assert(self.contestant.currentStamina >= self.requiredStamina, "Insufficient stamina.");

  if shouldCharge then

    chargeSwing(self);

  else

    local character = self.contestant.character;
    local bat = if character then character:FindFirstChild("Bat") else nil;
    assert(bat and bat:IsA("Accessory"), "The contestant's bat is missing.");

    swingBat(self, bat);

  end;

end;

function StrikeOutSwipeServerAction.__index:breakdown(): ()

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

  if self.remoteEvent then

    self.remoteEvent:Destroy();

  end;

  if self.contestant.player then

    ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(self.contestant.player, self.id);

  end;

end;

return StrikeOutSwipeServerAction;