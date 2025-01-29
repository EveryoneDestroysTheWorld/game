--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local TarBombClientAction = require(ReplicatedStorage.Client.Classes.Actions.TarBombClientAction);
local damageFramework = require(ServerStorage.Modules.DamageFramework);
local types = require(ServerStorage.Modules.types);

local TarBombServerAction = {
	id = TarBombClientAction.id;
	name = TarBombClientAction.name;
	description = TarBombClientAction.description;
	__index = {} :: types.TarBombServerAction;
};

local function startAttack(sourcePart: BasePart, animations, coords: Vector3, round: ServerRound, contestant: ServerContestant, split, size, useTarget, delay)
	print(size)
	if not delay then
		delay = 0.25
	end
	--[[ for testing to make sure projectile goes where it should
	local part = Instance.new("Part")
	part.Position = coords
	part.Anchored = true
	part.CanCollide = false
	part.Parent = workspace.Terrain
	]]
	if useTarget then 
		coords = contestant.character.Target.Value.PrimaryPart.Position 
	end
	local bomb = ReplicatedStorage.Shared.InGameDisplayObjects.TarBomb:Clone()
	bomb.Parent = workspace.Terrain
	bomb.Position = sourcePart.Position
	bomb.CanTouch = false
	
	bomb.Massless = false
	Instance.new("NoCollisionConstraint", bomb)
	bomb.NoCollisionConstraint.Part0 = bomb
	bomb.NoCollisionConstraint.Part1 = sourcePart
	bomb.BillboardGui.Size = UDim2.new(size, 0, size, 0)
	if not split then
    
		bomb.ParticleEmitter:Destroy()
		
	end
	local animateSprite = require(ReplicatedStorage.Shared.InGameDisplayObjects.SpriteAnimator)
	local data = {
		FrameRate = 30,
		Sprite = bomb.BillboardGui.ImageLabel,
		SpriteSheet = "4x4"
	}
	coroutine.wrap(animateSprite.animateSprite)(data, 1, true)


	local distance = (coords - bomb.Position)
	local time = distance.Magnitude / 32 + 0.4
	bomb.AssemblyLinearVelocity = Vector3.new(distance.X * 2 / time, (distance.Y + ((196.2/2) * (time/2))) ,distance.Z * 2 / time)
	task.wait(0.3)
	bomb.CanTouch = true
	local collisionConnect
	collisionConnect = bomb.Touched:Connect(function(touched)
		collisionConnect:Disconnect()
		Instance.new("WeldConstraint", bomb)
		
		local rayOrigin = bomb.Position
		local rayDirection
		if touched:IsA("Terrain") then
			rayDirection = Vector3.new(0,-10,0) 
		elseif (touched.Size.X * touched.Size.Y * touched.Size.Z) > 100 then
			rayDirection = bomb.AssemblyLinearVelocity
		else
			rayDirection = (touched.Position - bomb.Position) * 2
		end

		local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
		if not raycastResult then
			rayDirection = Vector3.new(0,-10,0) 
			raycastResult = workspace:Raycast(rayOrigin, rayDirection)
		end
		if raycastResult then
			bomb.Position = raycastResult.Position


			bomb.WeldConstraint.Part0 = bomb
			bomb.WeldConstraint.Part1 = touched
		else
			bomb.Anchored = true
		end
      
		task.wait(delay)
		local data = {
			["Size"] = size,
			["Knockback"] = size * 20,
			["PlayerDamage"] = size * 4	,
			["ObjectDamage"] = size * 3,
			["DamageFalloff"] = true,
			["KnockbackOwner?"] = false,
			["DamageOwner?"] = true,
			["KnockUpAmount"] = 0.5,
		}
		damageFramework.explosionEvent(bomb.Position, data, round, contestant)
		if split then
			local roll = math.random(2,10)
			for i=1, roll do
				local randomCoor = coords + Vector3.new(math.random(-100,100)/10,0,math.random(-100,100)/10)
				coroutine.wrap(startAttack)(bomb, animations, randomCoor, round, contestant, false, 8/roll, false, math.random(1,15/10))
			end
		end
		bomb.BillboardGui:Destroy()
		task.wait(2)
		bomb:Destroy()
	
	end)


	
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
  
	connect = event.OnServerEvent:Connect(function(_: Player, data: Vector3, useTarget, charge)
		connect:Disconnect();
		event:SetAttribute("Coords", data);
		event:SetAttribute("UseTarget", useTarget)
		event:SetAttribute("Charge", charge)
	end)

	event.Name = "GetData"
	event.Parent = player

	--coords request sent to player
	event.AttributeChanged:Wait()
	event.AttributeChanged:Wait()
	event.AttributeChanged:Wait()

	--coords recieved by player
	return event:GetAttribute("Coords") :: Vector3, event:GetAttribute("UseTarget"), event:GetAttribute("Charge")
	
end

function TarBombServerAction.new(): ServerAction

	local _contestant: ServerContestant?;
	local _round: ServerRound?;
	local anims;

	local function activate(self: ServerAction)

		if _contestant and _round and _contestant.player and _contestant.character and _contestant.currentHealth > 0 then

			local coords, useTarget, charge = getDataFromClient(_contestant.player);
			if _contestant.currentStamina >= 20 then

				-- Reduce the player's stamina.
				_contestant:updateStamina(math.max(0, _contestant.currentStamina - 10 - charge));
				local size = 2 + charge/10
--
				startAttack(_contestant.character.Head :: BasePart, anims, coords, _round, _contestant, true, size, useTarget);
        
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
			remoteFunction.Name = `{contestant.player.UserId}_{self.id}`;
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
		id = TarBombServerAction.id;
		description = TarBombServerAction.description;
		breakdown = breakdown;
		activate = activate;
		initialize = initialize;
	});

end;

return TarBombServerAction;
