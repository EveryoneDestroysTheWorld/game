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

function meleeAttackFramework.KeyDown(data)
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

	local connection
	connection = attackState.Destroying:Connect(function()
		connection:Disconnect()
		connection = nil
		animations[animationName]:AdjustSpeed((data.lightAttackSpeed or defaultData.lightAttackSpeed)/100)
	end)

	task.delay(0.1, function()
		repeat
			local tween = TweenService:Create(data.Contestant.character.HumanoidRootPart, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {AssemblyLinearVelocity = data.Contestant.character.HumanoidRootPart.AssemblyLinearVelocity + data.Contestant.character.HumanoidRootPart.CFrame.LookVector * 50})
			tween:Play()
			task.wait(0.1)
		until not connection
	end)

	task.wait(data.timeToCharge or defaultData.timeToCharge)
	if connection then
		data.Contestant:updateStamina(math.max(0, data.Contestant.currentStamina - ((data.heavyStamDrain or defaultData.heavyStamDrain) - (data.lightStamDrain or defaultData.lightStamDrain)))); -- since you already paid the cost for a light attack, reduce the heavy attack cost by that much
		connection:Disconnect()
		connection = nil
		print("That was a charged attack!!!")
		animations[animationName]:AdjustSpeed(1)
	else
		staminaDrain = (data.lightStamDrain or defaultData.lightStamDrain)
		print("That was a light attack")
	end



	return staminaDrain
end

function meleeAttackFramework.KeyRelease(data)
	local state = data.Contestant.character:FindFirstChild("MeleeAttackState")
	if state then state:Destroy() else warn("No keydown found, how strange!") 
	end
end

return meleeAttackFramework