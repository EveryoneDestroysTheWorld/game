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
  action.maxDamage = 20;
  action.requiredStamina = 5;
  action.touchedTimeLimitSeconds = 1;

  local function initializeAction()

    local player = action.contestant.player;
    if player then
    
      action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(shouldCharge: boolean)
      
        action:activate(shouldCharge);

      end);

      ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

    end;

  end;

  local function verifyArchetypeMode()

    local archetypeMode = action.contestant.attributes.archetypeMode;
    if archetypeMode == "Batter" then

      initializeAction();

    else

      action:breakdown();

    end;

  end;
  
  verifyArchetypeMode();

  action.modeChangedEvent = ServerStorage.Events.ArchetypeModeChanged.Event:Connect(function(contestantID: number)
  
    if contestantID == action.contestant.id then

      verifyArchetypeMode();

    end;

  end);

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

  if self.contestant.player then

    ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(self.contestant.player, self.id);

  end;

  if self.modeChangedEvent then

    self.modeChangedEvent:Disconnect();

  end;

end;

return StrikeOutSwipeServerAction;