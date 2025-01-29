--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local TarBombClientAction = require(ReplicatedStorage.Client.Classes.Actions.TarBombClientAction);
local types = require(ServerStorage.Modules.types);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local mergeTable = require(ReplicatedStorage.Shared.Modules.mergeTable);
local preloadAnimations = require(ServerStorage.Modules.preloadAnimations);
local chargeAttack = require(script.chargeAttack);
local startAttack = require(script.startAttack);

local TarBombServerAction = {
	id = TarBombClientAction.id;
	name = TarBombClientAction.name;
	description = TarBombClientAction.description;
	__index = {
		id = TarBombClientAction.id;
		name = TarBombClientAction.name;
		description = TarBombClientAction.description;
		maxChargeTimeMilliseconds = 2000;
	} :: types.TarBombServerAction;
};

function TarBombServerAction.new(properties: types.ServerActionConstructorProperties): types.TarBombServerAction

	local overwrittenProperties = {
		contestant = properties.contestant;
	};

	local action = (setmetatable(overwrittenProperties, TarBombServerAction) :: any) :: types.TarBombServerAction;

	local character = action.contestant.character;
	if character then

		local humanoid = character:FindFirstChild("Humanoid") :: Humanoid;
		local wingProp = (humanoid.Parent :: Instance):FindFirstChild("WingProp") :: Model;
		local wingsPropRight = wingProp:FindFirstChild("WingsPropRight") :: Instance;
		local wingsPropLeft = wingProp:FindFirstChild("WingsPropLeft") :: Instance;

		local animationTracks = {};

		animationTracks = mergeTable(animationTracks, preloadAnimations(wingsPropLeft:FindFirstChild("Animator") :: Animator, {
			left = 95242287519828
		}));

		animationTracks = mergeTable(animationTracks, preloadAnimations(wingsPropRight:FindFirstChild("Animator") :: Animator, {
			right = 89949470467953
		}));

		animationTracks = mergeTable(animationTracks, preloadAnimations(humanoid:FindFirstChild("Animator") :: Animator, {
			player = 85718382304634
		}));

		action.animationTracks = animationTracks;

	end;

	local player = action.contestant.player;
	if player then

		local remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(shouldCharge: boolean, coordinates: Vector3?, shouldUseTarget: boolean?)

			assert(typeof(shouldCharge) == "boolean");
			assert(not coordinates or typeof(coordinates) == "Vector3");
			assert(not shouldUseTarget or typeof(coordinates) == "boolean");

			return action:activate(shouldCharge, coordinates, shouldUseTarget);

		end);

		action.remoteFunction = remoteFunction;

	end

	return action;

end;

function TarBombServerAction.__index:activate(shouldCharge: boolean, coordinates: Vector3?, shouldUseTarget: boolean?)

	local draconicKnightTargetModel = self.contestant.attributes.draconicKnightTargetModel
	if shouldUseTarget and typeof(draconicKnightTargetModel) == "Model" and draconicKnightTargetModel.PrimaryPart then 

		coordinates = draconicKnightTargetModel.PrimaryPart.Position;

	end

	if self.contestant.currentStamina >= 20 then

		local character = self.contestant.character;
		assert(character);

		if shouldCharge then

			assert(character.PrimaryPart);
			chargeAttack(self, character.PrimaryPart);

		else

			assert(coordinates);
			local charge = 0;
			if self.startChargeTimeMilliseconds then

				local goalTime = self.startChargeTimeMilliseconds + self.maxChargeTimeMilliseconds;
				local queryTime = math.min(goalTime, DateTime.now().UnixTimestampMillis);
				charge = math.max(1, queryTime / goalTime) * 100;
				self.startChargeTimeMilliseconds = nil;
			
			end;

			-- Reduce the player's stamina.
			self.contestant:updateStamina(math.max(0, self.contestant.currentStamina - 10 - charge));
			local size = 2 + charge / 10
	--

			local sourcePart = character:FindFirstChild("Head") or character.PrimaryPart;
			assert(sourcePart and sourcePart:IsA("BasePart"));

			startAttack(self, sourcePart, coordinates, true, size);

		end;
		
	end

end
	
function TarBombServerAction.__index:breakdown()

	if self.remoteFunction then

		self.remoteFunction:Destroy();

	end

end

return TarBombServerAction;
