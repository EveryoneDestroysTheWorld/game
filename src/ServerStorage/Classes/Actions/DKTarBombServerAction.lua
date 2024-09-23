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
local TarBombClientAction = require(ReplicatedStorage.Client.Classes.Actions.DKTarBombClientAction);
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;
local ServerStorage = game:GetService("ServerStorage");

local TarBombServerAction = {
	ID = TarBombClientAction.ID;
	name = TarBombClientAction.name;
	description = TarBombClientAction.description;
};



local function damageEvent(primaryPart: BasePart, round: ServerRound, contestant: ServerContestant, size)

	local explosion = Instance.new("Explosion", primaryPart);
	explosion.BlastPressure = 0;
	explosion.BlastRadius = size;
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

				local newHealth = currentHealth - size*3;
				possibleEnemyContestant:updateHealth(newHealth, {
					contestant = contestant;
					actionID = TarBombServerAction.ID;
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

local function startAttack(primaryPart: BasePart, animations, coords: Vector3, round: ServerRound, contestant: ServerContestant, split)
	local bomb = ReplicatedStorage.Client.InGameDisplayObjects.DraconicKnight.TarBomb:Clone()
	bomb.Parent = workspace.Terrain
	bomb.Position = primaryPart.Position
	bomb.Anchored = true
	bomb.CanCollide = false
	local size = 5
	if not split then
		bomb.ParticleEmitter:Destroy()
		bomb.BillboardGui.Size = UDim2.new(3, 0, 3, 0)
		size = 2.5
	end
	local animateSprite = require(ReplicatedStorage.Client.InGameDisplayObjects.SpriteAnimator)
	local data = {
		FrameRate = 30,
		Sprite = bomb.BillboardGui.ImageLabel,
		SpriteSheet = "4x4"
	}
	coroutine.wrap(animateSprite.animateSprite)(data, 1, true)


	local distance = (bomb.Position - coords).Magnitude / 40
	if distance > 1 then 
		distance = 1 
	end
	local i = 0
	repeat
		local height = ((distance) - (math.abs(0.5-(i/distance)) * distance)) * 4
		local tween = TweenService:Create(bomb, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Position = (bomb.Position * (1-(i/distance))) + (coords * (i/distance)) + Vector3.new(0,height,0)})
		tween:Play()
		task.wait(0.1)
		i+=0.1
	until i > distance
	task.wait(1)
	damageEvent(bomb, round, contestant, size)
	if split then
		for i=1, math.random(4,6) do
			local randomCoor = coords + Vector3.new(math.random(-10,10),0,math.random(-10,10))
			coroutine.wrap(startAttack)(bomb, animations, randomCoor, round, contestant)
		end
	end
	bomb.BillboardGui:Destroy()
	task.wait(2)
	bomb:Destroy()
end


local function preloadAnims(char: Model): {[string]: AnimationTrack}

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

local function getDataFromClient(player: Player): Vector3

	local event = Instance.new("RemoteEvent")
	local connect
	connect = event.OnServerEvent:Connect(function(_: Player, data: Vector3)

		connect:Disconnect();
		event:SetAttribute("Coords", data);

	end)

	event.Name = "GetData"
	event.Parent = player

	--coords request sent to player
	event.AttributeChanged:Wait()

	--coords recieved by player
	return event:GetAttribute("Coords") :: Vector3;

end


function TarBombServerAction.new(): ServerAction

	local _contestant: ServerContestant?;
	local _round: ServerRound?;
	local anims;

	local function activate(self: ServerAction)

		if _contestant and _round and _contestant.player and _contestant.character then

			local coords = getDataFromClient(_contestant.player);
			if _contestant.currentStamina >= 20 then

				-- Reduce the player's stamina.
				_contestant:updateStamina(math.max(0, _contestant.currentStamina - 10));
				startAttack(_contestant.character.PrimaryPart :: BasePart, anims, coords, _round, _contestant, true);

			end

		end;

	end;

	local executeActionRemoteFunction: RemoteFunction? = nil;

	local function breakdown(self: ServerAction)

		if executeActionRemoteFunction then

			executeActionRemoteFunction:Destroy();

		end

	end;

	local function initialize(self: ServerAction, contestant: ServerContestant, round: ServerRound)

		_contestant = contestant;
		_round = round;

		if contestant.character then

			anims = preloadAnims(contestant.character);

		end;

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
		name = TarBombServerAction.name;
		ID = TarBombServerAction.ID;
		description = TarBombServerAction.description;
		breakdown = breakdown;
		activate = activate;
		initialize = initialize;
	});

end;




return TarBombServerAction;
