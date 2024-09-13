--!strict
-- Programmers: Hati ---- Heavily modified edit of RocketFeet
-- Designers: Christian Toney (Sudobeast)
-- © 2024 Beastslash LLC

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

local function damageEvent(primaryPart, round, contestant)
	print("creating Explosion")
		local explosion = Instance.new("Explosion", primaryPart);
		explosion.BlastPressure = 0;
		explosion.BlastRadius = 5;
		explosion.DestroyJointRadiusPercent = 0;
		explosion.Position = primaryPart.Position;
		local hitContestants = {};
		explosion.Hit:Connect(function(basePart)
  
		  -- Damage any parts or contestants that get hit.
		  for _, possibleEnemyContestant in ipairs(round.contestants) do
  
			task.spawn(function()
  
			  local possibleEnemyCharacter = possibleEnemyContestant.character;
			  if possibleEnemyContestant ~= contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then
  
				table.insert(hitContestants, possibleEnemyContestant);
				local enemyHumanoid = possibleEnemyCharacter:FindFirstChild("Humanoid");
				if enemyHumanoid then
  
				  local currentHealth = enemyHumanoid:GetAttribute("CurrentHealth") :: number?;
				  if currentHealth then
  
					local newHealth = currentHealth - 15;
					possibleEnemyContestant:updateHealth(newHealth, {
					  contestant = contestant;
					  actionID = DiveBombServerAction.ID;
					});
  
				  end
  
				end;
  
			  end;
  
			end);
  
		  end;
		  
		  local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability") :: number?;
		  if basePartCurrentDurability and basePartCurrentDurability > 0 then
  
			ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 35, contestant);
  
		  end;
  
		end);
  

	 

end

local function startAttack(primaryPart, animations, coords, round, contestant)
	local flightConstraint = primaryPart:FindFirstChild("FlightConstraint")
	if flightConstraint then
		flightConstraint:SetAttribute("PlayerControls", false)
	end
	primaryPart.CFrame = CFrame.lookAt((primaryPart.CFrame.Position), (coords * Vector3.new(1,0,1) + Vector3.new(0,primaryPart.CFrame.Position.Y,0)))
	--perhaps some of this could be clientside
	local animData = Vector3.new(0.1,1,1)
	animations["Right"]:Play(animData.X,animData.Y,animData.Z);
	animations["Left"]:Play(animData.X,animData.Y,animData.Z);
	animations["Player"]:Play(animData.X,animData.Y,animData.Z);

	local intialDistance = ((coords+Vector3.new(0,5,0)) - primaryPart.CFrame.Position).Magnitude
	local part = Instance.new("Part", workspace.Terrain);
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	Instance.new("RigidConstraint", part)
	part.RigidConstraint.Attachment0 = Instance.new("Attachment", part)
	part.CFrame = primaryPart.CFrame
	part.RigidConstraint.Attachment1 = primaryPart:FindFirstChild("RootAttachment")
	for i = 1, 5 do
		expectedPos = part.Position + (( part.CFrame.LookVector * -1 + Vector3.new(0,1/5,0)) * (5-i)) + ((part.CFrame.LookVector + Vector3.new(0,1/5,0)) * (i))
	local tween = TweenService:Create(part, TweenInfo.new(0.75/5, Enum.EasingStyle.Linear), {Position = expectedPos})
	tween:Play()
	task.wait(0.75/5)
	end
	animations["Right"]:AdjustSpeed(1.5);
	animations["Left"]:AdjustSpeed(1.5);
	animations["Player"]:AdjustSpeed(1.5);
	
	local travelDistance = ((coords+Vector3.new(0,5,0)) - primaryPart.CFrame.Position).Magnitude
	local travelTime = 8/15
	local tween = TweenService:Create(part, TweenInfo.new(travelTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = coords + Vector3.new(0,4,0)})
	tween:Play()
	task.wait(travelTime)
	damageEvent(primaryPart, round, contestant)

	
	animations["Right"]:AdjustSpeed(1);
	animations["Left"]:AdjustSpeed(1);
	animations["Player"]:AdjustSpeed(1);
	task.wait(0.2)
part:Destroy()
	return
end


local function preloadAnims(char, animations)

	local humanoid = char.Humanoid


	local animator = humanoid:FindFirstChild("Animator")
	local animatorR = humanoid.Parent.WingProp.WingsPropRight:FindFirstChild("AnimationController") or humanoid.Parent.WingProp.WingsPropRight:FindFirstChild("Animator");
	local animatorL = humanoid.Parent.WingProp.WingsPropLeft:FindFirstChild("AnimationController") or humanoid.Parent.WingProp.WingsPropLeft:FindFirstChild("Animator");
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
local humanoid = contestant.character.Humanoid
	local action: ServerAction = nil;

	local function activate()

		if contestant.character then
			local coords = getDataFromClient(contestant.player)
			print(coords)
			if humanoid:GetAttribute("CurrentStamina") >= 20 then
				-- Reduce the player's stamina.
				humanoid:SetAttribute("CurrentStamina", humanoid:GetAttribute("CurrentStamina") - 10)
			startAttack(contestant.character.HumanoidRootPart, anims, coords, round, contestant)
			end
		end;

	end;


	local executeActionRemoteFunction: RemoteFunction? = nil;

	local function breakdown()

		if executeActionRemoteFunction then

			executeActionRemoteFunction:Destroy();

		end

		

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
