--!strict
-- Programmer: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local FireBeamClientAction = require(ReplicatedStorage.Client.Classes.Actions.FireBeamClientAction);
local types = require(ServerStorage.Modules.types);

local createInventoryRemoteEvent = require(ServerStorage.Modules.createInventoryRemoteEvent);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local chargeAttack = require(script.chargeAttack);
local fireAttack = require(script.fireAttack);

local FireBeamServerAction = {
	id = FireBeamClientAction.id;
	name = FireBeamClientAction.name;
	description = FireBeamClientAction.description;
	__index = {
		name = FireBeamClientAction.name;
		id = FireBeamClientAction.id;
		description = FireBeamClientAction.description;
		charge = 0;
		maxChargeTimeMilliseconds = 2000;
	} :: types.FireBeamServerAction;
};

function FireBeamServerAction.new(properties: types.ServerActionConstructorProperties): types.FireBeamServerAction

	local overwrittenProperties = {
		contestant = properties.contestant;
	};
	
  local action = (setmetatable(overwrittenProperties, FireBeamServerAction) :: any) :: types.FireBeamServerAction;

	local player = action.contestant.player;
	if player then

		local remoteID = `{player.UserId}_{action.id}`;
		action.remoteFunction = createInventoryRemoteFunction(player, "Action", remoteID, function(shouldCharge: boolean)
    
			assert(not shouldCharge or typeof(shouldCharge) == "boolean");
      action:activate(shouldCharge);

    end);

		local remoteEvent = createInventoryRemoteEvent(player, "Action", remoteID);
		remoteEvent.OnServerEvent:Connect(function(player: Player, coordinates: Vector3)
		
			assert(player == action.contestant.player);
			assert(typeof(coordinates) == "Vector3");
			action.coordinates = coordinates;

		end);
		action.remoteEvent = remoteEvent;

		ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

	end

	return action;

end

function FireBeamServerAction.__index:activate(shouldCharge: boolean)

	local character = self.contestant.character;
	assert(character);

	local primaryPart = character.PrimaryPart;
	assert(primaryPart);

	local isContestantFlying = not not primaryPart:FindFirstChild("FlightConstraint");
	assert(isContestantFlying);

	if shouldCharge then

		chargeAttack(self, primaryPart);

	else

		fireAttack(self, primaryPart);

	end

end

function FireBeamServerAction.__index:breakdown()

	if self.remoteFunction then

		self.remoteFunction:Destroy();

	end

	if self.remoteEvent then

		self.remoteEvent:Destroy();

	end;

	if self.contestant.player then

    ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(self.contestant.player, self.id);

  end;

end

return FireBeamServerAction;