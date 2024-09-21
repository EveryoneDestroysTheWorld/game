--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Hati (hati_bati)
-- © 2024 Beastslash LLC

meleeAttackFramework = {}
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local ServerContestant = require(ServerStorage.Classes.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(ServerStorage.Classes.ServerAction);
type ServerAction = ServerAction.ServerAction;
local MeleeClientAction = require(ReplicatedStorage.Client.Classes.Actions.DKMeleeClientAction);
local ServerRound = require(ServerStorage.Classes.ServerRound);
type ServerRound = ServerRound.ServerRound;

local displayObjects = ReplicatedStorage.Client.InGameDisplayObjects

local defaultData = {
	animName = "Melee",
	maxCombo = 3,
	timeToCharge = 0.7,
	lightAttackSpeed = 120,
	heavyAttackSpeed = 50,
	lightAttackEffect = nil,
	heavyAttackEffect = nil,
	forwardMomentum = 6,
	heavyAttackMomentumMultiplier = 2,
	lightStamDrain = 10,
	heavyStamDrain = 20,
}

-- 			data template
-- 	{
-- 		Contestant = Contestant,  			--REQUIRED
-- 		Animations = Preloaded animations,  --REQUIRED IF START

-- 		animName = "Melee",
-- 		maxCombo = 3,
-- 		timeToCharge = 0.7,
-- 		lightAttackSpeed = 100,
-- 		heavyAttackSpeed = 60,
-- 		lightAttackEffect = nil,
-- 		heavyAttackEffect = nil,
-- 		forwardMomentum = 6,
-- 		heavyAttackMomentumMultiplier = 2,
-- 	}


local storedCombos = {}

function meleeAttackFramework.KeyDown(data: Array, effect: Function)
	data.Contestant:updateStamina(math.max(0, data.Contestant.currentStamina - (data.lightStamDrain or defaultData.lightStamDrain)));
	local combo = storedCombos[data.Contestant] or 1
	local animations = data.Animations
	local attackState = Instance.new("BoolValue", data.Contestant.character)
	attackState.Name = "MeleeAttackState"
	if combo == 1 then 
		storedCombos[data.Contestant] = 2
		animations[(data.animName or defaultData.animName)..tostring(data.maxCombo or defaultData.maxCombo)]:Stop(0.3)
	else
		if (data.maxCombo or defaultData.maxCombo) == combo then
			storedCombos[data.Contestant] = nil
		else
			storedCombos[data.Contestant] += 1
		end
		animations[(data.animName or defaultData.animName)..tostring(combo - 1)]:Stop(0.3)
	end
	local animationName = (data.animName or defaultData.animName) .. tostring(combo)
	local animData = Vector3.new(
		0.1, -- Time To Enter Animation
		1, -- weight
		(data.heavyAttackSpeed or defaultData.heavyAttackSpeed)/100 -- speed
	)
	animations[animationName]:Play(animData.X,animData.Y,animData.Z)
	local movementTween 
	local connection
	local playerFollowPart
	local posTarget
	local lookDirection = if data.Contestant.character.Humanoid.MoveDirection ~= Vector3.new(0,0,0) then Vector2.new(data.Contestant.character.Humanoid.MoveDirection.X,data.Contestant.character.Humanoid.MoveDirection.Z) else Vector2.new(data.Contestant.character.HumanoidRootPart.CFrame.LookVector.X,data.Contestant.character.HumanoidRootPart.CFrame.LookVector.Z)
	local updateLookDirection
	local debounce = false
	updateLookDirection = data.Contestant.character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		
		if not debounce then
			debounce = true
			lookDirection = if data.Contestant.character.Humanoid.MoveDirection ~= Vector3.new(0,0,0) then Vector2.new(data.Contestant.character.Humanoid.MoveDirection.X,data.Contestant.character.Humanoid.MoveDirection.Z) else lookDirection
			task.wait(0.1)
			debounce = false
			lookDirection = if data.Contestant.character.Humanoid.MoveDirection ~= Vector3.new(0,0,0) then Vector2.new(data.Contestant.character.Humanoid.MoveDirection.X,data.Contestant.character.Humanoid.MoveDirection.Z) else lookDirection
		end
	end)

		
		
		



	connection = attackState.Destroying:Connect(function()
		connection:Disconnect()
		connection = nil
		animations[animationName]:AdjustSpeed((data.lightAttackSpeed or defaultData.lightAttackSpeed)/100)
		movementTween:Cancel()
	end)

	local LVelc = Instance.new("LinearVelocity", data.Contestant.character.HumanoidRootPart)
	LVelc.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	LVelc.SecondaryTangentAxis = Vector3.new(0, 0, 1)
	
	LVelc.MaxForce = math.huge
	task.wait()
    LVelc.Attachment0 = Instance.new("Attachment", data.Contestant.character.HumanoidRootPart)
	
	local i = 1
	LVelc.PlaneVelocity = lookDirection * (data.forwardMomentum or defaultData.forwardMomentum) * 4 * (i/((data.timeToCharge or defaultData.timeToCharge) * 10))
	repeat
		
		movementTween = TweenService:Create(LVelc, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {PlaneVelocity = lookDirection * (data.forwardMomentum or defaultData.forwardMomentum) * 4 * ((i + 2)/((data.timeToCharge or defaultData.timeToCharge) * 10))})
		movementTween:Play()
		task.wait(0.1)
		i += 1
	until i > ((data.timeToCharge or defaultData.timeToCharge) * 10) or not connection
	LVelc:Destroy()

	if connection then
		if effect then
			coroutine.wrap(effect)(data.Contestant.character, combo)
		end
		data.Contestant:updateStamina(math.max(0, data.Contestant.currentStamina - ((data.heavyStamDrain or defaultData.heavyStamDrain) - (data.lightStamDrain or defaultData.lightStamDrain)))); -- since you already paid the cost for a light attack, reduce the heavy attack cost by that much
		connection:Disconnect()
		connection = nil
		animations[animationName]:AdjustSpeed(1)
	else

	end
	task.wait(0.5)
	updateLookDirection:Disconnect()

	return staminaDrain
end

function meleeAttackFramework.KeyRelease(data)
	local state = data.Contestant.character:FindFirstChild("MeleeAttackState")
	if state then state:Destroy() else warn("No keydown found, how strange!") 
	end
end

return meleeAttackFramework