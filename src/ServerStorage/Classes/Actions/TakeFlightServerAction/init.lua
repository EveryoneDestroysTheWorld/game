--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local ITakeFlightServerAction = require(ServerStorage.Interfaces.ITakeFlightServerAction);
local TakeFlightClientAction = require(ReplicatedStorage.Client.Classes.Actions.TakeFlightClientAction);

local animateFlight = require(script.animateFlight);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local mergeTable = require(ReplicatedStorage.Shared.Modules.mergeTable);
local endFlight = require(script.endFlight);
local preloadAnimations = require(ServerStorage.Modules.preloadAnimations);
local startFlight = require(script.startFlight);

type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;
type ITakeFlightServerAction = ITakeFlightServerAction.ITakeFlightServerAction;

local TakeFlightServerAction = {
	id = TakeFlightClientAction.id;
	name = TakeFlightClientAction.name;
	description = TakeFlightClientAction.description;
};

function TakeFlightServerAction.new(contestant: IServerContestant): ITakeFlightServerAction
	
	local animationTracks = {};
	local linearVelocity;

	local function activate(self: ITakeFlightServerAction): boolean

		if contestant.character and contestant.currentHealth > 0 then

			local humanoid = contestant.character:FindFirstChild("Humanoid");
			assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.character}'s Humanoid`);
	
			local primaryPart = contestant.character.PrimaryPart;
			if primaryPart then
	
				if primaryPart:FindFirstChild("FlightConstraint") then
	
					coroutine.wrap(endFlight)(self, primaryPart);
	
					animateFlight(self, primaryPart, Vector3.new(0, 100, 2.5), true);
	
				elseif contestant.currentStamina >= 10 then
	
					contestant:setCurrentStamina(math.max(0, contestant.currentStamina - 10), {
						actionID = self.id;
						contestantID = contestant.id;
					});
	
					coroutine.wrap(startFlight)(self, contestant, primaryPart);
	
					animateFlight(self, primaryPart, Vector3.new(0, 100, 1.8), false)
	
					return true;
	
				end
	
			end;
	
		end;
	
		return false;

	end;

	local function breakdown(self: ITakeFlightServerAction)

		if linearVelocity then

			linearVelocity:Destroy();

		end;

		if self.remoteFunction then

			self.remoteFunction:Destroy();

		end

		local character = contestant.character;
		if character then

			local wingProp = character:FindFirstChild("WingProp");

			if wingProp then

				wingProp:Destroy();

			end;

		end;

		if contestant.player then

			ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);

		end;

	end;

	local action: ITakeFlightServerAction = {
		attributes = {};
		contestantID = contestant.id;
		description = TakeFlightServerAction.description;
		id = TakeFlightServerAction.id;
		name = TakeFlightServerAction.name;
		activate = activate;
		breakdown = breakdown;
	}

	local character = contestant.character;
	local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
	if character and humanoid then

		local animator = humanoid:FindFirstChild("Animator") :: Animator;
		if animator then

			animationTracks = mergeTable(animationTracks, preloadAnimations(animator, {
				["end"] = 101417868579212,
				start = 92928175332389,
				idle = 109371600216543
			}));

		end;

		local wingProp = character:FindFirstChild("WingProp") :: Model;
		if wingProp then

			local wingPropRight = wingProp:FindFirstChild("WingsPropRight");
			local animatorR = if wingPropRight then wingPropRight:FindFirstChild("Animator") else nil;
			if animatorR and animatorR:IsA("AnimationController") then

				animationTracks = mergeTable(animationTracks, preloadAnimations(animatorR, {
					right = 87777396509498,
					rightIdle = 112159869158031,
				}));

			end;
			
			local wingPropLeft = wingProp:FindFirstChild("WingsPropLeft");
			local animatorL = if wingPropLeft then wingPropLeft:FindFirstChild("Animator") else nil;
			if animatorL and animatorL:IsA("AnimationController") then

				animationTracks = mergeTable(animationTracks, preloadAnimations(animatorL, {
					left = 72026942510156,
					leftIdle = 109626445218372,
				}));

			end;

		end;

	end;

	animationTracks = animationTracks;

	local player = contestant.player;
	if player then

		local remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function()

			return action:activate();

		end);

		action.remoteFunction = remoteFunction;
		
		ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

	end;

	return action;

end;

return TakeFlightServerAction;