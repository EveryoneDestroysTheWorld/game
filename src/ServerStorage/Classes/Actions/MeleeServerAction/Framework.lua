--!strict
-- Programmer: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");

local types = require(ServerStorage.Classes.types);

local mAnimate2
local meleeAttackFramework = {}

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

export type KeyDownData = {
	contestant: types.ServerContestant;
	animations: {AnimationTrack};
	animName: string?;
	maxCombo: number?;
	timeToCharge: number?;
	lightAttackSpeed: number?;
	heavyAttackSpeed: number?;
	forwardMomentum: number?;
	heavyAttackMomentumMultiplier: number?;
	lightStamDrain: number?;
	heavyStamDrain: number;
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

local currentlyAttacking = {}
function meleeAttackFramework.KeyDown(data: KeyDownData, effect: (...any) -> (any), round, archetypeABRV: string)

	if not currentlyAttacking[data.contestant] then

		currentlyAttacking[data.contestant] = true
		data.contestant:updateStamina(math.max(0, data.contestant.currentStamina - (data.lightStamDrain or defaultData.lightStamDrain)));
		local combo = storedCombos[data.contestant] or 1
		local animations = data.animations

		if combo == 1 then 

			storedCombos[data.contestant] = 2
			animations[(data.animName or defaultData.animName)..tostring(data.maxCombo or defaultData.maxCombo)]:Stop(0.3)

		else

			if (data.maxCombo or defaultData.maxCombo) == combo then

				storedCombos[data.contestant] = nil

			else

				storedCombos[data.contestant] += 1

			end

			animations[`{data.animName or defaultData.animName}{combo - 1}`]:Stop(0.3)

		end
		
		local animationName = `{data.animName or defaultData.animName}{combo}`;
		local animData = Vector3.new(
			0.1, -- Time To Enter Animation
			1, -- weight
			(data.heavyAttackSpeed or defaultData.heavyAttackSpeed)/100 -- speed
		)
		animations[animationName]:Play(animData.X,animData.Y,animData.Z)
      
		if not mAnimate2 then

			mAnimate2 = require(ReplicatedStorage.Client.InGameDisplayObjects.MoonAnimator);

		end

		mAnimate2.animateCFrame(data.contestant.character, ReplicatedStorage.Client.InGameDisplayObjects:FindFirstChild(`{archetypeABRV}AnimData`):FindFirstChild(animationName))
		local movementTween 
		local lookDirection = if data.contestant.character.Humanoid.MoveDirection ~= Vector3.new(0,0,0) then data.contestant.character.Humanoid.MoveDirection else data.contestant.character.HumanoidRootPart.CFrame.LookVector
		local updateLookDirection
		local debounce = false

		updateLookDirection = data.contestant.character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		
			if not debounce then
				debounce = true
				lookDirection = if data.contestant.character.Humanoid.MoveDirection ~= Vector3.new(0,0,0) then Vector3.new(data.contestant.character.Humanoid.MoveDirection.X,0,data.contestant.character.Humanoid.MoveDirection.Z) else lookDirection
				task.wait(0.1)
				debounce = false
				lookDirection = if data.contestant.character.Humanoid.MoveDirection ~= Vector3.new(0,0,0) then Vector3.new(data.contestant.character.Humanoid.MoveDirection.X,0,data.contestant.character.Humanoid.MoveDirection.Z) else lookDirection
			end
		end)

		
		
		
		timeToCharge = (data.timeToCharge or defaultData.timeToCharge)
		task.wait(timeToCharge/3)

		i = 0
		repeat
			if currentlyAttacking[data.contestant] ~= true then
				i = 4
				animations[animationName]:AdjustSpeed(1.2,0.1)
			else
				i += 1
				task.wait(timeToCharge/6)
			end
		until i == 4

		local function hurt(damage)

			local hurtBox = Instance.new("Part", data.contestant.character:FindFirstChild("HumanoidRootPart"))
			hurtBox.Name = "HurtBox";
			hurtBox.Transparency = 1;
			hurtBox.Anchored = true;
			hurtBox.CanCollide = false;
			hurtBox.CFrame = data.contestant.character:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(Vector3.new(0, 0, -10));
			hurtBox.Size = Vector3.new(7, 7, 7);

			local foundParts = workspace:GetPartsInPart(hurtBox)
			local validTargets = {}
			for i, part in ipairs(foundParts) do
				local model = part:FindFirstAncestorOfClass("Model")
				if model and not table.find(validTargets, model.Name) and model:FindFirstChild("Humanoid") and model.Name ~= data.contestant.character.Name then
					table.insert(validTargets, model.Name)
				end
			end

			if #validTargets > 0 then
				
				for _, contestant in round.contestants do

					if contestant.name == validTargets[table.find(validTargets, contestant.name)] then

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

		local LVelc
		if currentlyAttacking[data.contestant] == true then
			animations[animationName]:AdjustSpeed(1.2,0.1)
			LVelc = Instance.new("LinearVelocity", data.contestant.character.HumanoidRootPart)
			LVelc.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
			--LVelc.SecondaryTangentAxis = Vector3.new(0, 0, 1)
	
			LVelc.MaxForce = math.huge
			task.wait()
    		LVelc.Attachment0 = Instance.new("Attachment", data.contestant.character.HumanoidRootPart)
			LVelc.LineDirection = lookDirection
		
			if effect then
				coroutine.wrap(effect)(data.contestant.character, combo)
			end
			data.contestant:updateStamina(math.max(0, data.contestant.currentStamina - ((data.heavyStamDrain or defaultData.heavyStamDrain) - (data.lightStamDrain or defaultData.lightStamDrain)))); -- since you already paid the cost for a light attack, reduce the heavy attack cost by that much
			connection = nil
			animations[animationName]:AdjustSpeed(1)
			task.delay(0.24,function()
				hurt(30)
			end)
			i = 0
			repeat
				movementTween = TweenService:Create(LVelc, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {LineVelocity = (data.forwardMomentum or defaultData.forwardMomentum) * (4-i), LineDirection = lookDirection})
				movementTween:Play()
				task.wait(0.1)
				i += 1
			until i > timeToCharge * 4
			task.wait(0.2)
			if LVelc then
				LVelc:Destroy()
			end
			
		else
			task.delay(0.2,function()
				hurt(10)
			end)
			task.wait(0.3)
		end
	
	


	
		task.wait(0.3)
		if currentlyAttacking[data.contestant] == "buffered" or currentlyAttacking[data.contestant] == "buffered2" then
			if currentlyAttacking[data.contestant] == "buffered2" then
				task.delay(0.3,function()
					currentlyAttacking[data.contestant] = "buttonReleased"
				end)
			end
			currentlyAttacking[data.contestant] = false
			
			meleeAttackFramework.KeyDown(data, effect, round)
		else
			currentlyAttacking[data.contestant] = false
		end
		updateLookDirection:Disconnect()


	elseif currentlyAttacking[data.contestant] == true then

		currentlyAttacking[data.contestant] = "buttonReleased"
		--print("State is buttonReleased")

	elseif currentlyAttacking[data.contestant] == "buttonReleased" then

		--print("State is buffered")
		currentlyAttacking[data.contestant] = "buffered"

	else

		--print("State is buffered2")
		currentlyAttacking[data.contestant] = "buffered2"

	end

	return staminaDrain

end

return meleeAttackFramework