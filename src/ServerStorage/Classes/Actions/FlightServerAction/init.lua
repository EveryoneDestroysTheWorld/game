--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local TakeFlightClientAction = require(ReplicatedStorage.Client.Classes.Actions.FlightClientAction);
local types = require(ServerStorage.Classes.types);

local animateFlight = require(script.animateFlight);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local endFlight = require(script.endFlight);
local preloadAnimations = require(ServerStorage.Modules.preloadAnimations);
local startFlight = require(script.startFlight);

local TakeFlightServerAction = {
	id = TakeFlightClientAction.id;
	name = TakeFlightClientAction.name;
	description = TakeFlightClientAction.description;
	__index = {} :: types.TakeFlightServerAction;
};

function TakeFlightServerAction.new(properties: types.ServerActionConstructorProperties): types.TakeFlightServerAction
	
	local overwrittenProperties = {
		name = TakeFlightServerAction.name;
		id = TakeFlightServerAction.id;
		description = TakeFlightServerAction.description;
		contestant = properties.contestant;
		round = properties.round;
	};

  local action = (setmetatable(overwrittenProperties, TakeFlightServerAction) :: any) :: types.TakeFlightServerAction;

	local animationTracks = {};

	local character = action.contestant.character;
	local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
	if character and character:IsA("Humanoid") and humanoid and humanoid:IsA("Humanoid") then

		local function updateAnimationTracks(animator: Animator, assetIDs: {[string]: number}): ()

			local newTracks = preloadAnimations(humanoid, animator, assetIDs);
			
			for key, track in newTracks do

				animationTracks[key] = track;

			end;

		end;

		local animator = humanoid:FindFirstChild("Animator") :: Animator;
		if animator then

			updateAnimationTracks(animator, {
				["end"] = 101417868579212,
				start = 92928175332389,
				idle = 109371600216543
			});

		end;

		local wingProp = character:FindFirstChild("WingProp") :: Model;
		if wingProp then

			local wingPropRight = wingProp:FindFirstChild("WingsPropRight");
			local animatorR = if wingPropRight then wingPropRight:FindFirstChild("Animator") else nil;
			if animatorR and animatorR:IsA("Animator") then

				updateAnimationTracks(animatorR, {
					right = 87777396509498,
					rightIdle = 112159869158031,
				});

			end;
			
			local wingPropLeft = wingProp:FindFirstChild("WingsPropLeft");
			local animatorL = if wingPropLeft then wingPropLeft:FindFirstChild("Animator") else nil;
			if animatorL and animatorL:IsA("Animator") then

				updateAnimationTracks(animatorL, {
					left = 72026942510156,
					leftIdle = 109626445218372,
				});

			end;

		end;

	end;

	action.animationTracks = animationTracks;

	local player = action.contestant.player;
	if player then

		local remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function()

			action:activate();

		end);

		action.remoteFunction = remoteFunction;

	end;

	return action;

end;

function TakeFlightServerAction.__index:activate()

	if self.contestant.character and self.contestant.currentHealth > 0 then

		local humanoid = self.contestant.character:FindFirstChild("Humanoid");
		assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {self.contestant.character}'s Humanoid`);

		local primaryPart = self.contestant.character.PrimaryPart;
		if humanoid:GetState() == Enum.HumanoidStateType.Freefall and primaryPart then

			if primaryPart:FindFirstChild("FlightConstraint") then

				coroutine.wrap(endFlight)(primaryPart);

				animateFlight(self, primaryPart, Vector3.new(0, 100, 2.5), true);

			elseif self.contestant.currentStamina >= 10 then

				self.contestant:updateStamina(math.max(0, self.contestant.currentStamina - 10));

				coroutine.wrap(startFlight)(self.contestant, primaryPart);

				animateFlight(self, primaryPart, Vector3.new(0, 100, 1.8), false)

			end

		end;

	end;

end

function TakeFlightServerAction.__index:breakdown()

	if self.remoteFunction then

		self.remoteFunction:Destroy();

	end

	local character = self.contestant.character;
	if character then

		local wingProp = character:FindFirstChild("WingProp");

		if wingProp then

			wingProp:Destroy();

		end;

	end;

end

return TakeFlightServerAction;