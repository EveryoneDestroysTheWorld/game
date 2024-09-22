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
	actionID = 8
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

function meleeAttackFramework.KeyDown(data: Array, effect: Function, round)
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
	local lookDirection = if data.Contestant.character.Humanoid.MoveDirection ~= Vector3.new(0,0,0) then data.Contestant.character.Humanoid.MoveDirection else data.Contestant.character.HumanoidRootPart.CFrame.LookVector
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

		
		
		
	timeToCharge = (data.timeToCharge or defaultData.timeToCharge)

	local i = 2
	connection = attackState.Destroying:Connect(function()
		connection:Disconnect()
		connection = nil
		animations[animationName]:AdjustSpeed((data.lightAttackSpeed or defaultData.lightAttackSpeed)/100)
		i = 3.1
	end)

	
	
	local LVelc
	task.wait(0.3)
	if i < 3 then
		LVelc = Instance.new("LinearVelocity", data.Contestant.character.HumanoidRootPart)
		LVelc.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
		--LVelc.SecondaryTangentAxis = Vector3.new(0, 0, 1)
	
		LVelc.MaxForce = math.huge
		task.wait()
    	LVelc.Attachment0 = Instance.new("Attachment", data.Contestant.character.HumanoidRootPart)
		LVelc.LineDirection = lookDirection
	repeat
		movementTween = TweenService:Create(LVelc, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {LineVelocity = (data.forwardMomentum or defaultData.forwardMomentum) * 4 * ((i + 1)/((data.timeToCharge or defaultData.timeToCharge) * 10)), LineDirection = lookDirection})
		movementTween:Play()
		task.wait(0.1)
		i += 1
	until i > timeToCharge * 10
	end
	local function hurt(damage)
		local hurtBox = Instance.new("Part", data.Contestant.character:FindFirstChild("HumanoidRootPart"))
		hurtBox.Name = "HurtBox"
		hurtBox = data.Contestant.character:FindFirstChild("HumanoidRootPart"):FindFirstChild("HurtBox")
		hurtBox.Anchored = true
		hurtBox.CanCollide = false
		hurtBox.CFrame = data.Contestant.character:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(Vector3.new(0,0,-10))
		hurtBox.Size = Vector3.new(7,7,7)

		local foundParts = Workspace:GetPartsInPart(hurtBox)
		local validTargets = {}
		for i, part in ipairs(foundParts) do
			local model = part:FindFirstAncestorOfClass("Model")
			if model and not table.find(validTargets, model.Name) and model:FindFirstChild("Humanoid") and model.Name ~= data.Contestant.character.Name then
				table.insert(validTargets, model.Name)
			end
		end
		if #validTargets > 0 then
			
			for i, contestant in ipairs(round.contestants) do
				if contestant["name"] == validTargets[table.find(validTargets, contestant["name"])] then
					contestant:updateHealth(contestant.currentHealth - damage, {
						contestant = contestant;
						actionID = actionID;
					});
				end
			end
		end
		task.wait(0.1)
		hurtBox:Destroy()
	end

	if connection then
		if effect then
			coroutine.wrap(effect)(data.Contestant.character, combo)
		end
		data.Contestant:updateStamina(math.max(0, data.Contestant.currentStamina - ((data.heavyStamDrain or defaultData.heavyStamDrain) - (data.lightStamDrain or defaultData.lightStamDrain)))); -- since you already paid the cost for a light attack, reduce the heavy attack cost by that much
		connection:Disconnect()
		connection = nil
		animations[animationName]:AdjustSpeed(1)
		task.delay(0.24,function()
			hurt(30)
		end)
		i = 0
		if LVelc then
			LVelc.LineDirection = lookDirection
			LVelc.LineVelocity = (data.forwardMomentum or defaultData.forwardMomentum) * (data.heavyAttackMomentumMultiplier or defaultData.heavyAttackMomentumMultiplier) * 4
		movementTween = TweenService:Create(LVelc, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {LineVelocity = 0})
		movementTween:Play()
		end
		task.wait(0.5)
	else
		task.delay(0.2,function()
			hurt(10)
		end)
	end
	
	


	
	task.wait(0.3)
	if LVelc then
	LVelc:Destroy()
	end
	
	updateLookDirection:Disconnect()

	return staminaDrain
end

function meleeAttackFramework.KeyRelease(data)
	local state = data.Contestant.character:FindFirstChild("MeleeAttackState")
	if state then state:Destroy() else warn("No keydown found, how strange!") 
	end
end


function meleeAttackFramework.Attack(data: Array, effect: Function, round)
	if not data.Contestant.character:FindFirstChild("ButtonDown") then
		buttonDown = Instance.new("BoolValue", data.Contestant.character)
		buttonDown.Name = "ButtonDown"
	end
	if not buttonDown.Value then
		buttonDown.Value = true
	else
		buttonDown.Value = false
	end
	if buttonDown.Value then
		if not debounce then
			debounce = true
			meleeAttackFramework.KeyDown(data, meleeAttackEffect, round)
			if debounce == "buffered" then
				debounce = false
				meleeAttackFramework.KeyDown(data, meleeAttackEffect, round)
			end
			debounce = false
		else
			debounce = "buffered"
		end
	elseif debounce == "buffered" then
		meleeAttackFramework.KeyRelease(data)
	else
		meleeAttackFramework.KeyRelease(data)
	end

end

return meleeAttackFramework