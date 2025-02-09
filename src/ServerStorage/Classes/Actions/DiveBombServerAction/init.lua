--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney) and Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local DiveBombClientAction = require(ReplicatedStorage.Client.Classes.Actions.DiveBombClientAction);
local types = require(ServerStorage.Modules.types);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local startAttack = require(script.startAttack);
local groundDash = require(script.groundDash);

local DiveBombServerAction = {
	id = DiveBombClientAction.id;
	name = DiveBombClientAction.name;
	description = DiveBombClientAction.description;
	__index = {
		name = DiveBombClientAction.name;
		id = DiveBombClientAction.id;
		description = DiveBombClientAction.description;
	} :: types.DiveBombServerAction;
};

function DiveBombServerAction.new(properties: types.ServerActionConstructorProperties): types.DiveBombServerAction

	local overwrittenProperties = {
		contestant = properties.contestant;
	};

	local action = (setmetatable(overwrittenProperties, DiveBombServerAction) :: any) :: types.DiveBombServerAction;

	if action.contestant.character then

		local function preloadAnims(char: Model)

			local humanoid = char:FindFirstChild("Humanoid") :: Humanoid;
			local wingProp = (humanoid.Parent :: Instance):FindFirstChild("WingProp") :: Model;
			local wingsPropRight = wingProp:FindFirstChild("WingsPropRight") :: Instance;
			local wingsPropLeft = wingProp:FindFirstChild("WingsPropLeft") :: Instance;
			local animationAssets: {[string]: {animator: Animator; assetID: number}} = {
				Left = {
					animator = wingsPropLeft:FindFirstChild("Animator") :: Animator;
					assetID = 95242287519828;
				};
				Right = {
					animator = wingsPropRight:FindFirstChild("Animator") :: Animator;
					assetID = 89949470467953;
				};
				Player = {
					animator = humanoid:FindFirstChild("Animator") :: Animator;
					assetID = 85718382304634;
				};
			}
		
			local animationTracks = {};
			for key, data in pairs(animationAssets) do
		
				local animation = Instance.new("Animation");
				animation.AnimationId = `rbxassetid://{data.assetID};`
				animationTracks[key] = data.animator:LoadAnimation(animation);
		
			end;
		
			return animationTracks;
		
		end

		action.anims = preloadAnims(action.contestant.character);

	end;

	local player = action.contestant.player;
	if player then

		action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(coordinates, shouldUseTarget)
		
			assert(typeof(coordinates) == "Vector3");
			assert(typeof(shouldUseTarget) == "boolean");

			action:activate(coordinates, shouldUseTarget);

		end);

		ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

	end

	return action;

end;

function DiveBombServerAction.__index:activate(coordinates: Vector3, shouldUseTarget: boolean)

	if self.contestant and self.contestant.character and self.contestant.currentHealth > 0 and self.contestant.currentStamina >= 20 then

		-- Reduce the player's stamina.
		self.contestant:updateStamina(math.max(0, self.contestant.currentStamina - 10), {
			actionID = self.id;
		});
		
		local flightConstraint = self.contestant.character.PrimaryPart:FindFirstChild("FlightConstraint");
		if flightConstraint then

			startAttack(self, self.contestant.character.PrimaryPart :: BasePart, self.anims, coordinates);

		else

			groundDash(self, self.contestant.character.PrimaryPart :: BasePart, self.anims, coordinates, shouldUseTarget);
		
		end

	end

end;

function DiveBombServerAction.__index:breakdown()

	if self.remoteFunction then

		self.remoteFunction:Destroy();

	end

	if self.contestant.player then

    ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(self.contestant.player, self.id);

  end;

end;

return DiveBombServerAction;
