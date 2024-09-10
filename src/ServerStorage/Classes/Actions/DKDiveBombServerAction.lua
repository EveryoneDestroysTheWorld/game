--!strict
-- Writer: Hati ---- Heavily modified edit of RocketFeet
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local DiveBombClientAction = require(ReplicatedStorage.Client.Classes.Actions.DKDiveBombClientAction);
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;
local ServerStorage = game:GetService("ServerStorage");

local DiveBombServerAction = {
	ID = DiveBombClientAction.ID;
	name = DiveBombClientAction.name;
	description = DiveBombClientAction.description;
};

local function animateFlight(humanoid,animations, animData,state)

	animations["Right"]:Play(animData.X,animData.Y,animData.Z);
	animations["Left"]:Play(animData.X,animData.Y,animData.Z);

	if state and state == "EndFlight" then
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

local function flightStart(primaryPart)
	--perhaps some of this could be clientside
	local linearVelocity = Instance.new("LinearVelocity");
	linearVelocity.VelocityConstraintMode = "Line"
	linearVelocity.LineDirection = Vector3.new(0, 1, 0);
	linearVelocity.LineVelocity = -5
	linearVelocity.MaxForce = math.huge;
	linearVelocity.Parent = primaryPart;
	linearVelocity.Attachment0 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;
	linearVelocity:SetAttribute("PlayerControls", false)
	task.wait(0.3)

	linearVelocity.LineVelocity = 50;

	local tween = TweenService:Create(linearVelocity, TweenInfo.new(1.0, Enum.EasingStyle.Sine), {LineVelocity = 0})
	tween:Play()
	task.wait(0.6)
	linearVelocity.VelocityConstraintMode = "Vector"
	linearVelocity.VectorVelocity = Vector3.new(0,0,0)
	linearVelocity:SetAttribute("PlayerControls", true)
	local humanoid = primaryPart.Parent.Humanoid

	local connection
	connection = humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function(change)
		if humanoid.FloorMaterial ~= Enum.Material.Air then
			connection:Disconnect()
			linearVelocity:Destroy()
		end
	end)


	repeat 
		task.wait(0.25)
		humanoid:SetAttribute("CurrentStamina", humanoid:GetAttribute("CurrentStamina") - 2)
	until linearVelocity:GetAttribute("PlayerControls") == false or humanoid:GetAttribute("CurrentStamina") <= 0
	if humanoid:GetAttribute("CurrentStamina") <= 0 then
		linearVelocity:SetAttribute("PlayerControls", false)
		linearVelocity.VelocityConstraintMode = "Line"
		linearVelocity.LineDirection = Vector3.new(0, -1, 0);
		linearVelocity.LineVelocity = 8

	end
	return
end

local function flightEnd(primaryPart)
	local linearVelocity = primaryPart:FindFirstChild("LinearVelocity")
	linearVelocity:SetAttribute("PlayerControls", false)

	linearVelocity.VelocityConstraintMode = "Line"
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

local function preloadAnims(char, animations)

	local humanoid = char.Humanoid


	local animator = humanoid:FindFirstChild("Animator")
	local animatorR = humanoid.Parent.WingProp.WingsPropRight:FindFirstChild("AnimationController");
	local animatorL = humanoid.Parent.WingProp.WingsPropLeft:FindFirstChild("AnimationController");
	local anims = {}

	-- usually would have a for i here, but since different animators are used this way is easier
	anims["Right"] = Instance.new("Animation");
	anims["Right"].AnimationId = "rbxassetid://89949470467953";
	animations["Right"] = animatorR:LoadAnimation(anims["Right"]);

	anims["Left"] = Instance.new("Animation");
	anims["Left"].AnimationId = "rbxassetid://95242287519828";
	animations["Left"] = animatorL:LoadAnimation(anims["Left"]);


	anims["Player"] = Instance.new("Animation");
	anims["Player"].AnimationId = "rbxassetid://85718382304634";
	animations["Player"] = animator:LoadAnimation(anims["Player"])

	return animations
end

local function getDataFromClient(player)
	local event = Instance.new("RemoteEvent")
	local connect
	connect = event.OnServerEvent:Connect(function(p, data)
		connect:Disconnect()
	event:SetAttribute("Coords", data)
	end)
	event.Name = "GetData"
	event.Parent = player
	--coords request sent to player
	event.AttributeChanged:Wait()
	--coords recieved by player
	return event:GetAttribute("Coords")
end


function DiveBombServerAction.new(contestant: ServerContestant, round: ServerRound, data): ServerAction

	
	local animations = {
		"Right, 89949470467953",
		"Left, 95242287519828",
		"Player, 85718382304634",
	};

	local anims = preloadAnims(contestant.character, animations)

	local action: ServerAction = nil;

	local function activate()

		if contestant.character then

			print(data)

		end;

	end;


	local executeActionRemoteFunction: RemoteFunction? = nil;

	local function breakdown()

		if executeActionRemoteFunction then

			executeActionRemoteFunction:Destroy();

		end

		contestant.character.WingProp:Destroy()

	end;




	action = ServerAction.new({
		name = DiveBombServerAction.name;
		ID = DiveBombServerAction.ID;
		description = DiveBombServerAction.description;
		breakdown = breakdown;
		activate = activate;
	});

	if contestant.player then

		local remoteFunction = Instance.new("RemoteFunction");
		remoteFunction.Name = `{contestant.player.UserId}_{action.ID}`;
		remoteFunction.OnServerInvoke = function(player)

			if player == contestant.player then

				local data = getDataFromClient(contestant.player)
	print(data)

				action:activate();

			else

				-- That's weird.
				error("Unauthorized.");

			end

		end;
		remoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
		executeActionRemoteFunction = remoteFunction;

	end

	return action;

end;




return DiveBombServerAction;