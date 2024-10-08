--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local TakeFlightClientAction = require(ReplicatedStorage.Client.Classes.Actions.DKFlightClientAction);
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;


local TakeFlightServerAction = {
	ID = TakeFlightClientAction.ID;
	name = TakeFlightClientAction.name;
	description = TakeFlightClientAction.description;
};


local function animateFlight(humanoid: Humanoid, animations, animData, isEndingFlight: boolean)

	animations["Right"]:Play(animData.X,animData.Y,animData.Z);
	animations["Left"]:Play(animData.X,animData.Y,animData.Z);

	if isEndingFlight then

		animations["RightIdle"]:Stop(0.1)
		animations["LeftIdle"]:Stop(0.1)
		animations["Idle"]:Stop(0.1)
		animations["End"]:Play(0.1,1,0.8)
		task.wait(0.3)
		animations["End"]:AdjustWeight(0.01,0.5)

	else
		animations["Start"]:Play(0.1,1,1.8)
		task.wait(0.5)
		animations["Start"]:AdjustWeight(0.01,0.5)
		animations["Idle"]:Play(0.5,1,1.2)
		animations["RightIdle"]:Play(0.5,1,1.2)
		animations["LeftIdle"]:Play(0.5,1,1.2)
		task.wait(0.3)
		local connection
		connection = humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function(change)
			if humanoid.FloorMaterial ~= Enum.Material.Air then
				connection:Disconnect()
				animations["RightIdle"]:Stop(0.5)
				animations["LeftIdle"]:Stop(0.5)
				animations["Idle"]:Stop(0.5)
			end
		end)

	end


	return animations
end

local function flightStart(contestant: ServerContestant, primaryPart: BasePart)

	--perhaps some of this could be clientside
	local linearVelocity = Instance.new("LinearVelocity");
  linearVelocity.Name = "FlightConstraint"
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line;
	linearVelocity.LineDirection = Vector3.new(0, 1, 0);
	linearVelocity.LineVelocity = -5
	linearVelocity.MaxForce = math.huge;
	linearVelocity.Parent = primaryPart;
	linearVelocity.Attachment0 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;
	linearVelocity:SetAttribute("PlayerControls", false);

	task.wait(0.3)

	linearVelocity.LineVelocity = 50;

	local tween = TweenService:Create(linearVelocity, TweenInfo.new(1.0, Enum.EasingStyle.Sine), {LineVelocity = 0});
	tween:Play()
	task.wait(0.6)

	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector;
	linearVelocity.VectorVelocity = Vector3.new(0,0,0)
	linearVelocity:SetAttribute("PlayerControls", true)
	local humanoid = (primaryPart.Parent :: Instance):FindFirstChild("Humanoid") :: Humanoid;
	local connection
	connection = humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function(change)

		if humanoid.FloorMaterial ~= Enum.Material.Air then

			connection:Disconnect()
			linearVelocity:Destroy()

		end

	end)

	repeat 

		task.wait(0.25)
		contestant:updateStamina(math.max(0, contestant.currentStamina - 2));

	until not linearVelocity:GetAttribute("PlayerControls") or contestant.currentStamina <= 0

	if contestant.currentStamina <= 0 then

		linearVelocity:SetAttribute("PlayerControls", false)
		linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line;
		linearVelocity.LineDirection = Vector3.new(0, -1, 0);
		linearVelocity.LineVelocity = 8

	end
	
end

local function flightEnd(primaryPart: BasePart)

	local linearVelocity = primaryPart:FindFirstChild("FlightConstraint") :: LinearVelocity;
	linearVelocity:SetAttribute("PlayerControls", false);

	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line;
	linearVelocity.LineDirection = Vector3.new(0, 1, 0);
	linearVelocity.LineVelocity = 15
	linearVelocity.MaxForce = math.huge;
	linearVelocity.Parent = primaryPart;
	linearVelocity.Attachment0 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;

	task.wait(0.15)
	linearVelocity.LineDirection = primaryPart.CFrame.LookVector
	linearVelocity.LineVelocity = 30;
	task.delay(0.1, function()

		linearVelocity:Destroy();

	end);

end


local function preloadAnims(char: Model, animations: any)

	local humanoid = char:FindFirstChild("Humanoid") :: Humanoid;

	local animator = humanoid:FindFirstChild("Animator") :: Animator;
	local wingProp = char:FindFirstChild("WingProp") :: Model;
	local animatorR = (wingProp:FindFirstChild("WingsPropRight") :: Model):FindFirstChild("Animator") :: Animator;
	local animatorL = (wingProp:FindFirstChild("WingsPropLeft") :: Model):FindFirstChild("Animator") :: Animator;

	local anims = {}

	-- usually would have a for i here, but since different animators are used this way is easier
	anims["Right"] = Instance.new("Animation");
	anims["Right"].AnimationId = "rbxassetid://87777396509498";
	animations["Right"] = animatorR:LoadAnimation(anims["Right"]);

	anims["RightIdle"] = Instance.new("Animation");
	anims["RightIdle"].AnimationId = "rbxassetid://112159869158031";
	animations["RightIdle"] = animatorR:LoadAnimation(anims["RightIdle"]);

	anims["Left"] = Instance.new("Animation");
	anims["Left"].AnimationId = "rbxassetid://72026942510156";
	animations["Left"] = animatorL:LoadAnimation(anims["Left"]);

	anims["LeftIdle"] = Instance.new("Animation");
	anims["LeftIdle"].AnimationId = "rbxassetid://109626445218372";
	animations["LeftIdle"] = animatorL:LoadAnimation(anims["LeftIdle"]);

	anims["End"] = Instance.new("Animation");
	anims["End"].AnimationId = "rbxassetid://101417868579212";
	animations["End"] = animator:LoadAnimation(anims["End"])

	anims["Start"] = Instance.new("Animation");
	anims["Start"].AnimationId = "rbxassetid://92928175332389";
	animations["Start"] = animator:LoadAnimation(anims["Start"])

	anims["Idle"] = Instance.new("Animation");
	anims["Idle"].AnimationId = "rbxassetid://109371600216543";
	animations["Idle"] = animator:LoadAnimation(anims["Idle"]);

	return animations
end

function TakeFlightServerAction.new(): ServerAction

	local contestant: ServerContestant;

	local animations = {
		Right = 87777396509498,
		RightIdle = 112159869158031,
		Left = 72026942510156,
		LeftIdle = 109626445218372,
		End = 101417868579212,
		Start = 92928175332389,
		Idle = 109371600216543,
	};

	local anims;

	local function activate()

		if contestant.character then

			local humanoid = contestant.character:FindFirstChild("Humanoid");
			assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.character}'s Humanoid`);

			local primaryPart = contestant.character.PrimaryPart;
			if humanoid:GetState() == Enum.HumanoidStateType.Freefall and primaryPart then

				if primaryPart:FindFirstChild("FlightConstraint") then

					local animData = Vector3.new(0, 100, 2.5);
					coroutine.wrap(flightEnd)(primaryPart);
					anims = animateFlight(humanoid, anims, animData, true);

				elseif contestant.currentStamina >= 10 then

					-- Reduce the player's stamina.
					contestant:updateStamina(math.max(0, contestant.currentStamina - 10));
					local animData = Vector3.new(0,100,1.8)
					coroutine.wrap(flightStart)(contestant, primaryPart)
					anims = animateFlight(humanoid, anims, animData, false)

				end

			end;

		end;

	end;


	local executeActionRemoteFunction: RemoteFunction? = nil;

	local function breakdown()

		if executeActionRemoteFunction then

			executeActionRemoteFunction:Destroy();

		end


		if contestant.character then

			local wingProp = contestant.character:FindFirstChild("WingProp");
			if wingProp then

				wingProp:Destroy();

			end;

		end;

	end;

	local function initialize(self: ServerAction, newContestant: ServerContestant)

    contestant = newContestant;

		anims = preloadAnims(contestant.character :: Model, animations)

		if contestant.player then

			local remoteFunction = Instance.new("RemoteFunction");
			remoteFunction.Name = `{contestant.player.UserId}_{self.ID}`;
			remoteFunction.OnServerInvoke = function(player)
	
				if player == contestant.player then
	
					self:activate();
	
				else
	
					-- That's weird.
					error("Unauthorized.");
	
				end
	
			end;
			remoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
			executeActionRemoteFunction = remoteFunction;
	
		end

	end;

	return ServerAction.new({
		name = TakeFlightServerAction.name;
		ID = TakeFlightServerAction.ID;
		description = TakeFlightServerAction.description;
		breakdown = breakdown;
		activate = activate;
		initialize = initialize;
	});

end;

return TakeFlightServerAction;