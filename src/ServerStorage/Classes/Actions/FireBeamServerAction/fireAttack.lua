--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local displayObjects = ReplicatedStorage.Shared.InGameDisplayObjects;
local types = require(ServerStorage.Modules.types);

local animateSprite = require(ReplicatedStorage.Shared.Modules.animateSprite);

local function fireAttack(action: types.FireBeamServerAction, primaryPart: BasePart)

	if not action.startChargeTimeMilliseconds then

		return;

	end;

	local chargeMeter = primaryPart:FindFirstChild("ChargeMeter") :: Instance;

	local data = {
		frameRate = 128,
		sprite = chargeMeter:FindFirstChild("Sprite") :: ImageLabel,
		spriteSheet = "8x8"
	}

	local goalTime = action.startChargeTimeMilliseconds + action.maxChargeTimeMilliseconds;
	local queryTime = math.min(goalTime, DateTime.now().UnixTimestampMillis);
	action.charge = math.max(1, queryTime / goalTime) * 100;

	if action.charge >= 15 then

		local character = primaryPart.Parent;
		assert(character);

		local head = character:FindFirstChild("Head");
		assert(head);

		local faceCenterAttachment = head:FindFirstChild("FaceCenterAttachment");
		assert(faceCenterAttachment and faceCenterAttachment:IsA("Attachment"));

		if action.remoteEvent and action.contestant.player then

			action.remoteEvent:FireClient(action.contestant.player, true);

		end;

		local fireBeamProp = displayObjects.DraconicKnight:FindFirstChild("FireBeamProp"):Clone()
		fireBeamProp.Parent = primaryPart.Parent
		fireBeamProp.Root.Position = faceCenterAttachment.WorldPosition
		fireBeamProp.AlignPosition.Attachment1 = faceCenterAttachment
		local putOnPlayer = fireBeamProp.PutOnPlayer.HumanoidRootPart:GetChildren()
		for _, item in putOnPlayer do

			item.Parent = primaryPart

		end
		fireBeamProp.PutOnPlayer:Destroy()

		local fireWallProps = {}
		fireBeamProp.Target.Position = action.coordinates or Vector3.zero;
		fireBeamProp.Target.CanTouch = true
		fireBeamProp.Target.Size = Vector3.new(4,4,4)
		local damageConnect = {}
		local connectDebounce = {}

		local function setOnFire(model: Model)

			local existingFireDebuffProp = model:FindFirstChild("FireDebuffProp");
			if existingFireDebuffProp then 

				existingFireDebuffProp:SetAttribute("Duration", 6)
				
			else
				
				local humanoidRootPart = model:FindFirstChild("HumanoidRootPart");
				if humanoidRootPart then

					local newFireDebuffProp = displayObjects.FireDebuffProp:Clone();
					newFireDebuffProp.Parent = model
					newFireDebuffProp.RigidConstraint.Attachment1 = humanoidRootPart:FindFirstChild("RootAttachment")
					newFireDebuffProp:SetAttribute("Duration", 6)
					newFireDebuffProp.Highlight.Adornee = model
			
					task.delay(1/30, function()

						while newFireDebuffProp:GetAttribute("Duration") ~= 0 and task.wait(1) do
							
							newFireDebuffProp:SetAttribute("Duration", newFireDebuffProp:GetAttribute("Duration") :: number - 1)
							for _, contestant in action.contestant.round.contestants do

								if contestant.character and contestant.character == model then

									--print(contestant)

									contestant:updateHealth(contestant.currentHealth - 4, {
										contestantID = action.contestant.id;
										actionID = action.id;
									});
									
								end

							end

						end 

						newFireDebuffProp:Destroy()

					end)

				end;

			end

		end

		damageConnect[1] = fireBeamProp.Target.Touched:Connect(function(touched)

			if not connectDebounce["All"] then

				connectDebounce["All"] = true
				task.delay(1/30, function()

					connectDebounce["All"] = false

				end)

				local model = touched:FindFirstAncestorOfClass("Model")
				if not connectDebounce[model] then

					connectDebounce[model] = true
					task.delay(0.5, function()
					
						connectDebounce[model] = false
					
					end)
					setOnFire(model)
				
				end
			
			end
		
		end)
		
		repeat

			local rate = 6
			fireWallProps[#fireWallProps + 1] = fireBeamProp.Target:Clone()
			fireWallProps[#fireWallProps].Parent = fireBeamProp
			fireWallProps[#fireWallProps].Name = tostring(#fireWallProps)
			if #fireWallProps >= 2 then

				fireWallProps[#fireWallProps - 1].CFrame = CFrame.lookAt(fireWallProps[#fireWallProps - 1].Position, fireWallProps[#fireWallProps].Position)
				fireWallProps[#fireWallProps - 1].Position = (fireWallProps[#fireWallProps - 1].Position + fireWallProps[#fireWallProps].Position) / 2
				fireWallProps[#fireWallProps - 1].Size = Vector3.new(1,1,((fireWallProps[#fireWallProps - 1].Position - fireWallProps[#fireWallProps].Position).Magnitude)*2)
				fireWallProps[#fireWallProps - 1].FireAfter.Rate = fireWallProps[#fireWallProps - 1].Size.Z
				rate += fireWallProps[#fireWallProps - 1].Size.Z / 2

				damageConnect[#damageConnect] = fireWallProps[#fireWallProps - 1].Touched:Connect(function(touched)

					if not connectDebounce["All"] then

						connectDebounce["All"] = true
						task.delay(1/30, function()

							connectDebounce["All"] = false

						end)

						local model = touched:FindFirstAncestorOfClass("Model")
						if not connectDebounce[model] then

							connectDebounce[model] = true
							task.delay(0.5, function()

								connectDebounce[model] = false

							end)
							setOnFire(model)

						end

					end

				end)

			end
			local distance = (fireBeamProp.Particles.Atch.WorldPosition - fireBeamProp.Target.Position).Magnitude * 4
			local tween1 = TweenService:Create(fireBeamProp.Target, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Position = action.coordinates or Vector3.zero})
			tween1:Play()

			fireBeamProp.Particles.Fire.Speed = NumberRange.new(distance,distance)
			coroutine.wrap(animateSprite)(data, action.charge / 100)
			action.charge -= rate;

			task.wait(0.2)

		until action.charge <= 0

		action.startChargeTimeMilliseconds = nil;
		fireBeamProp.Particles:Destroy()
		fireBeamProp.Root:Destroy()
		fireBeamProp.Target.FireAfter.Rate = 0

		fireWallProps[#fireWallProps - 1].CFrame = CFrame.lookAt(fireWallProps[#fireWallProps - 1].Position, fireBeamProp.Target.Position)
		fireWallProps[#fireWallProps - 1].Position = (fireWallProps[#fireWallProps - 1].Position + fireBeamProp.Target.Position) / 2
		fireWallProps[#fireWallProps - 1].Size = Vector3.new(3,3,((fireWallProps[#fireWallProps - 1].Position - fireBeamProp.Target.Position).Magnitude)*2)

		task.delay(1/15, function()

			local tween = TweenService:Create(fireBeamProp.Target, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = Vector3.new(fireBeamProp.Target.Position.X,primaryPart.Position.Y,fireBeamProp.Target.Position.Z)})
			tween:Play()
			task.wait(0.5)

			for i, item in ipairs(putOnPlayer) do

				item:Destroy()

			end

		end)

		task.delay(5, function()

			for i, item in ipairs(fireWallProps) do
				item.FireAfter.Rate = 0
			end

			task.wait(2)
			fireBeamProp:Destroy()

			for i, con in ipairs(damageConnect) do

				con:Disconnect()

			end

		end)
	
	end
	
	if action.remoteEvent and action.contestant.player then

		action.remoteEvent:FireClient(action.contestant.player, false);

	end;

	coroutine.wrap(animateSprite)(data, 0)

	task.delay(1, function()

		chargeMeter:Destroy()

	end)

end

return fireAttack;