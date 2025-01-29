--!strict
-- Programmer: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Hati (hati_bati)
-- © 2024 – 2025 Everyone Destroys the World Group LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");

local types = require(ServerStorage.Modules.types);

local mAnimate2 = require(ReplicatedStorage.Shared.Modules.MoonAnimator);
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
	lightStaminaDrain = 10,
	heavyStaminaDrain = 20,
}

export type KeyDownData = {
	contestant: types.ServerContestant;
	animations: {[any]: AnimationTrack};
	animName: string?;
	maxCombo: number?;
	timeToCharge: number?;
	lightAttackSpeed: number?;
	heavyAttackSpeed: number?;
	forwardMomentum: number?;
	heavyAttackMomentumMultiplier: number?;
	lightStaminaDrain: number?;
	heavyStaminaDrain: number?;
	actionID: string;
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

export type AttackState = "Processing" | "Buffered" | "Buffered2" | "ButtonReleased";

local currentlyAttacking: {
	[types.ServerContestant]: AttackState
} = {}
function meleeAttackFramework.KeyDown(data: KeyDownData, effect: (...any) -> (any), round, archetypeABRV: string)

	local shouldRepeat = false;
	repeat

		if not currentlyAttacking[data.contestant] then

			currentlyAttacking[data.contestant] = "Processing"
			data.contestant:updateStamina(math.max(0, data.contestant.currentStamina - (data.lightStaminaDrain or defaultData.lightStaminaDrain)));
			local combo = storedCombos[data.contestant] or 1
			local animations = data.animations

			if combo == 1 then 

				storedCombos[data.contestant] = 2
				animations[`{data.animName or defaultData.animName}{data.maxCombo or defaultData.maxCombo}`]:Stop(0.3)

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

			local character = data.contestant.character;
			assert(character);

			local primaryPart = character.PrimaryPart;
			assert(primaryPart);

			local humanoid = character:FindFirstChild("Humanoid");
			assert(humanoid and humanoid:IsA("Humanoid"));

			mAnimate2.animateCFrame(character, ReplicatedStorage.Shared.InGameDisplayObjects:FindFirstChild(`{archetypeABRV}AnimData`):FindFirstChild(animationName))
			local movementTween 
			local lookDirection = if humanoid.MoveDirection ~= Vector3.new(0,0,0) then humanoid.MoveDirection else primaryPart.CFrame.LookVector
			local updateLookDirection
			local debounce = false

			updateLookDirection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			
				if not debounce then
					debounce = true
					lookDirection = if humanoid.MoveDirection ~= Vector3.new(0,0,0) then Vector3.new(humanoid.MoveDirection.X,0, humanoid.MoveDirection.Z) else lookDirection
					task.wait(0.1)
					debounce = false
					lookDirection = if humanoid.MoveDirection ~= Vector3.new(0,0,0) then Vector3.new(humanoid.MoveDirection.X, 0, humanoid.MoveDirection.Z) else lookDirection
				end

			end)		
			
			local timeToCharge = data.timeToCharge or defaultData.timeToCharge;
			task.wait(timeToCharge/3)

			local i = 0
			repeat
				
				if currentlyAttacking[data.contestant] then
				
					i += 1
					task.wait(timeToCharge / 6)
				
				else
				
					animations[animationName]:AdjustSpeed(1.2);
					break;
				
				end
			
			until i == 4

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart");
			assert(humanoidRootPart and humanoidRootPart:IsA("BasePart"));

			local function hurt(damage: number)

				local hurtBox = Instance.new("Part");
				hurtBox.Name = "HurtBox";
				hurtBox.Transparency = 1;
				hurtBox.Anchored = true;
				hurtBox.CanCollide = false;
				hurtBox.CFrame = humanoidRootPart.CFrame * CFrame.new(Vector3.new(0, 0, -10));
				hurtBox.Size = Vector3.new(7, 7, 7);
				hurtBox.Parent = humanoidRootPart;

				local foundParts = workspace:GetPartsInPart(hurtBox)
				local blockedModels = {}
				for i, part in foundParts do

					local model = part:FindFirstAncestorOfClass("Model");

					if model and not table.find(blockedModels, model) and model:FindFirstChild("Humanoid") and model.Name ~= character.Name then

						for _, contestant in round.contestants do

							if contestant.character == model then

								table.insert(blockedModels, model);

								contestant:updateHealth(contestant.currentHealth - damage, {
									contestant = contestant;
									actionID = data.actionID;
								});

								break;

							end;

						end;

					end

				end

				task.wait(0.1)
				hurtBox:Destroy()

			end

			local linearVelocity;

			if currentlyAttacking[data.contestant] == "Processing" then

				animations[animationName]:AdjustSpeed(1.2);
				linearVelocity = Instance.new("LinearVelocity");
				linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
		
				linearVelocity.MaxForce = math.huge
				linearVelocity.Parent = humanoidRootPart;
				task.wait()

				local attachment = Instance.new("Attachment");
				attachment.Parent = humanoidRootPart;
				linearVelocity.Attachment0 = attachment;
				linearVelocity.LineDirection = lookDirection
			
				if effect then
					coroutine.wrap(effect)(data.contestant.character, combo)
				end

				data.contestant:updateStamina(math.max(0, data.contestant.currentStamina - ((data.heavyStaminaDrain or defaultData.heavyStaminaDrain) - (data.lightStaminaDrain or defaultData.lightStaminaDrain)))); -- since you already paid the cost for a light attack, reduce the heavy attack cost by that much
				animations[animationName]:AdjustSpeed(1)

				task.delay(0.24,function()

					hurt(30)

				end)

				i = 0
				repeat
					movementTween = TweenService:Create(linearVelocity, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {LineVelocity = (data.forwardMomentum or defaultData.forwardMomentum) * (4-i), LineDirection = lookDirection})
					movementTween:Play()
					task.wait(0.1)
					i += 1
				until i > timeToCharge * 4

				task.wait(0.2)

				if linearVelocity then

					linearVelocity:Destroy()

				end
				
			else

				task.delay(0.2, function()

					hurt(10)

				end)

				task.wait(0.3)

			end

			task.wait(0.3)

			if currentlyAttacking[data.contestant] == "Buffered" or currentlyAttacking[data.contestant] == "Buffered2" then

				if currentlyAttacking[data.contestant] == "Buffered2" then

					task.delay(0.3,function()

						currentlyAttacking[data.contestant] = "ButtonReleased";

					end)

				end

				currentlyAttacking[data.contestant] = nil;
				shouldRepeat = true;

			else

				currentlyAttacking[data.contestant] = nil;

			end

			updateLookDirection:Disconnect()

		elseif currentlyAttacking[data.contestant] == "Processing" then

			currentlyAttacking[data.contestant] = "ButtonReleased"

		elseif currentlyAttacking[data.contestant] == "ButtonReleased" then

			currentlyAttacking[data.contestant] = "Buffered"

		else

			currentlyAttacking[data.contestant] = "Buffered2"

		end

	until not shouldRepeat;

end

return meleeAttackFramework