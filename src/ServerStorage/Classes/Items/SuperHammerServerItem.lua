--!strict
-- This module represents a Super Hammer on the server side. 
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerItem = require(script.Parent.Parent.ServerItem);
type ServerItem = ServerItem.ServerItem;
local SuperHammerClientItem = require(ReplicatedStorage.Client.Classes.Items.SuperHammerClientItem);
type Mode = SuperHammerClientItem.Mode;
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local SuperHammerServerItem = {
  ID = SuperHammerClientItem.ID;
  name = SuperHammerClientItem.name;
  description = SuperHammerClientItem.description;
};

function SuperHammerServerItem.new(): ServerItem

  local _contestant: ServerContestant?;
  local _round: ServerRound?;
  local _mode: Mode = "Dequipped";
  local _meshPart: MeshPart?;
  local _remoteFunction: RemoteFunction?;
  local _itemNumber: number?;
  local _chargeTime: number?;

  local function activate(self: ServerItem, mode: Mode): ()
    
    if mode == "Equipped" then

      assert(_contestant and _contestant.character and _meshPart);

      -- Run the equip animation.
      _meshPart.Parent = _contestant.character;
      _mode = mode;

    elseif mode == "Dequipped" then

      -- Run the de-equip animation.
      assert(_meshPart);

      _meshPart.CanCollide = false;
      _meshPart.Transparency = 1;

    elseif mode == "Swing" then

      _mode = mode;

      local maxChargeBonusMultiplier = 1.2;
      local maxChargeSeconds = 3;
      local actualChargeBonusMultiplier = (if _chargeTime then math.min((os.time() - _chargeTime) / maxChargeSeconds, maxChargeBonusMultiplier) else 1);
      local baseDamage = 100;
      local actualDamage = baseDamage * actualChargeBonusMultiplier;

      _chargeTime = nil;

      -- Play the swing animation.


    elseif mode == "Charge" then

      _mode = mode;
      _chargeTime = os.time();

      -- Play the charge animation.
      
    else

      warn(`Unknown mode selected: {mode}`);

    end;
    
  end;
  
  local function breakdown(self: ServerItem)

    if _contestant and _contestant.player then

      ReplicatedStorage.Shared.Functions.BreakdownItem:InvokeClient(_contestant.player, self.ID);

    end;
    
  end;

  local function initialize(self: ServerItem, contestant: ServerContestant)

    print(0);
    _contestant = contestant;
    local meshPart = ServerStorage.MeshParts.SuperHammer:Clone();
    meshPart:SetAttribute("Durability", 100);
    _meshPart = meshPart;

    print(1)

    if contestant.player then

      print(3);
      _remoteFunction, _itemNumber = createInventoryRemoteFunction(contestant.player, self.ID, function(mode: unknown)
      
        assert(mode == "Dequipped" or mode == "Equipped" or mode == "Swing" or mode == "Charge");
        self:activate(mode);

      end);

      print(2);
      ReplicatedStorage.Shared.Functions.InitializeItem:InvokeClient(contestant.player, self.ID, _itemNumber);

    end;

  end;

  local item = ServerItem.new({
    ID = SuperHammerServerItem.ID;
    name = SuperHammerServerItem.name;
    description = SuperHammerServerItem.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });
  
  return item;

end;

return SuperHammerServerItem;
