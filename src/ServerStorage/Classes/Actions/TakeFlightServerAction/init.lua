--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local ITakeFlightServerAction = require(ServerStorage.Interfaces.ITakeFlightServerAction);
local TakeFlightClientAction = require(ReplicatedStorage.Client.Classes.Actions.TakeFlightClientAction);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local mergeTable = require(ReplicatedStorage.Shared.Modules.mergeTable);
local preloadAnimations = require(ServerStorage.Modules.preloadAnimations);

type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;
type ITakeFlightServerAction = ITakeFlightServerAction.ITakeFlightServerAction;

local TakeFlightServerAction = {
	id = TakeFlightClientAction.id;
	name = TakeFlightClientAction.name;
	description = TakeFlightClientAction.description;
};

function TakeFlightServerAction.new(contestant: IServerContestant): ITakeFlightServerAction
	
	local animationTracks: {[string]: AnimationTrack} = {};
	local linearVelocity: LinearVelocity?;

	local function activate(self: ITakeFlightServerAction): boolean

		if contestant.character and contestant.currentHealth > 0 then

			local humanoid = contestant.character:FindFirstChild("Humanoid");
			assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.character}'s Humanoid`);
	
			local primaryPart = contestant.character.PrimaryPart;
			if primaryPart then

				local shouldEndFlight = not not primaryPart:FindFirstChild("FlightConstraint");
				local function animateFlight(animationData: Vector3)

					animationTracks.right:Play(animationData.X, animationData.Y, animationData.Z);
					animationTracks.left:Play(animationData.X, animationData.Y, animationData.Z);

					if shouldEndFlight then

						animationTracks.rightIdle:Stop(0.1)
						animationTracks.leftIdle:Stop(0.1)
						animationTracks.idle:Stop(0.1)
						animationTracks["end"]:Play(0.1,1,0.8)
						task.wait(0.3)
						animationTracks["end"]:AdjustWeight(0.01, 0.5)

					else
						animationTracks.start:Play(0.1,1,1.8)
						task.wait(0.5)
						animationTracks.start:AdjustWeight(0.01, 0.5)
						animationTracks.idle:Play(0.5, 1, 1.2)
						animationTracks.rightIdle:Play(0.5, 1, 1.2)
						animationTracks.leftIdle:Play(0.5, 1, 1.2)
						task.wait(0.3)

						local flightConstraint = primaryPart:FindFirstChild("FlightConstraint");
						if flightConstraint then

							flightConstraint.Destroying:Once(function(change)
								
								animationTracks.rightIdle:Stop(0.3)
								animationTracks.leftIdle:Stop(0.3)
								animationTracks.idle:Stop(0.3)

							end)

						end;

					end

				end;
	
				if shouldEndFlight then
					
					local function endFlight()

						if linearVelocity then

							local cachedLinearVelocity = linearVelocity;
							linearVelocity.VectorVelocity = Vector3.new(0,15,0)
							linearVelocity.MaxAxesForce = Vector3.new(math.huge,math.huge,math.huge);
							linearVelocity.Parent = primaryPart;
							linearVelocity.Attachment0 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;
					
							task.wait(0.15)
							linearVelocity.VectorVelocity = primaryPart.CFrame.LookVector * 30
							task.delay(0.1, function()
					
								if linearVelocity and linearVelocity == cachedLinearVelocity then
					
									linearVelocity = nil;
									linearVelocity:Destroy();
					
								end;
					
							end);
					
						end;

					end;

					endFlight();
					animateFlight(Vector3.new(0, 100, 2.5));
	
				elseif contestant.currentStamina >= 10 then
	
					contestant:setCurrentStamina(math.max(0, contestant.currentStamina - 10), {
						actionID = self.id;
						contestantID = contestant.id;
					});

					local function startFlight()

						--perhaps some of this could be clientside
						local newLinearVelocity = Instance.new("LinearVelocity");
						newLinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector;
						newLinearVelocity.Name = "FlightConstraint"
						newLinearVelocity.VectorVelocity = Vector3.new(0,-5,0)
						newLinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
						newLinearVelocity.MaxAxesForce = Vector3.new(0,math.huge,0);
						newLinearVelocity.Parent = primaryPart;
						newLinearVelocity.Attachment0 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;
						linearVelocity = newLinearVelocity;

						task.wait(0.3)

						newLinearVelocity.VectorVelocity = Vector3.new(0,50,0)

						local tween = TweenService:Create(linearVelocity, TweenInfo.new(1.0, Enum.EasingStyle.Sine), {VectorVelocity = Vector3.new(0,5,0)});
						tween:Play()
						task.wait(0.6)
						local humanoid = (primaryPart.Parent :: Instance):FindFirstChild("Humanoid") :: Humanoid;
						local connection
						connection = humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function(change)

							if humanoid.FloorMaterial ~= Enum.Material.Air then

								connection:Disconnect();

								if linearVelocity then

									linearVelocity:Destroy();
									linearVelocity = nil;

								end;

							end

						end)

						task.spawn(function()
						
							while linearVelocity == newLinearVelocity and RunService.Stepped:Wait() do

								local verticalVelocity = if humanoid.Jump then 0.8 else 0;
								local value = (humanoid.MoveDirection) + Vector3.new(0, verticalVelocity, 0)
								local tween = TweenService:Create(linearVelocity, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {VectorVelocity = value * 20})
								tween:Play()

							end;

						end);

						while contestant.currentStamina <= 0 or not primaryPart:FindFirstChild("FlightConstraint") or newLinearVelocity ~= linearVelocity and task.wait(0.25) do

							contestant:setCurrentStamina(math.max(0, contestant.currentStamina - 2), {
								actionID = self.id;
								contestantID = contestant.id;
							});

						end;

						if contestant.currentStamina <= 0 and linearVelocity then

							linearVelocity.LineDirection = Vector3.new(0, -8, 0);

						end

					end;
	
					task.spawn(startFlight);
					animateFlight(Vector3.new(0, 100, 1.8))
	
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