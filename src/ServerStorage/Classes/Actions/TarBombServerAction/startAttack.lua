--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local damageFramework = require(ServerStorage.Modules.DamageFramework);
local types = require(ServerStorage.Modules.types);

local animateSprite = require(ReplicatedStorage.Shared.Modules.animateSprite);

local function startAttack(action: types.TarBombServerAction, sourcePart: BasePart, coordinates: Vector3, split: boolean, size: number, explosionDelaySeconds: number?)

	--[[ for testing to make sure projectile goes where it should
	local part = Instance.new("Part")
	part.Position = coords
	part.Anchored = true
	part.CanCollide = false
	part.Parent = workspace.Terrain
	]]

	local bomb = ReplicatedStorage.Shared.InGameDisplayObjects.TarBomb:Clone()
	bomb.Parent = workspace.Terrain
	bomb.Position = sourcePart.Position
	bomb.CanTouch = false
	bomb.Massless = false

	local noCollisionConstraint = Instance.new("NoCollisionConstraint");
	noCollisionConstraint.Parent = bomb;
	bomb.NoCollisionConstraint.Part0 = bomb
	bomb.NoCollisionConstraint.Part1 = sourcePart
	bomb.BillboardGui.Size = UDim2.new(size, 0, size, 0)

	if not split then
    
		bomb.ParticleEmitter:Destroy()
		
	end

	local data = {
		frameRate = 30,
		sprite = bomb.BillboardGui.ImageLabel,
		spriteSheet = "4x4"
	}

	coroutine.wrap(animateSprite)(data, 1, true)

	local distance = (coordinates - bomb.Position)
	local time = distance.Magnitude / 32 + 0.4
	bomb.AssemblyLinearVelocity = Vector3.new(distance.X * 2 / time, (distance.Y + ((196.2/2) * (time/2))) ,distance.Z * 2 / time)
	task.wait(0.3)
	bomb.CanTouch = true
	local collisionConnect
	collisionConnect = bomb.Touched:Connect(function(part: BasePart)
		
		collisionConnect:Disconnect()
		local weld = Instance.new("WeldConstraint");
		weld.Parent = bomb;

		local rayOrigin = bomb.Position
		local rayDirection
		if part:IsA("Terrain") then

			rayDirection = Vector3.new(0, -10, 0) 

		elseif (part.Size.X * part.Size.Y * part.Size.Z) > 100 then

			rayDirection = bomb.AssemblyLinearVelocity

		else

			rayDirection = (part.Position - bomb.Position) * 2

		end

		local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
		if not raycastResult then

			rayDirection = Vector3.new(0, -10, 0) 
			raycastResult = workspace:Raycast(rayOrigin, rayDirection)

		end

		if raycastResult then

			bomb.Position = raycastResult.Position
			bomb.WeldConstraint.Part0 = bomb
			bomb.WeldConstraint.Part1 = part

		else

			bomb.Anchored = true

		end
    
		local defaultExplosionDelaySeconds = 0.25;
		task.wait(explosionDelaySeconds or defaultExplosionDelaySeconds);

		local data = {
			size = size,
			knockback = size * 20,
			playerDamage = size * 4	,
			objectDamage = size * 3,
			damageFalloff = true,
			knockbackOwner = false,
			damageOwner = true,
			knockUpAmount = 0.5,
		}

		damageFramework.explosionEvent(bomb.Position, data, action)
		if split then

			local bombletCount = math.random(2, 10);
			local bombletSize = size / math.random(2, 4);
			for i = 1, bombletCount do

				local scatterCoordinates = coordinates + Vector3.new(math.random(-100, 100) / 10, 0, math.random(-100, 100) / 10);
				coroutine.wrap(startAttack)(action, bomb, scatterCoordinates, false, bombletSize, math.random(1, 1.5));

			end

		end

		bomb.BillboardGui:Destroy()
		task.wait(2)
		bomb:Destroy()
	
	end)
	
end

return startAttack;