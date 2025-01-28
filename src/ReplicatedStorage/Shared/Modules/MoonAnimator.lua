--!strict
-- Programmers: Hati (hati_bati) and Christian Toney
-- © 2024 – 2025 Beastslash LLC

local RunService = game:GetService("RunService")

local mAnimate2 = {}

local function mathOrderArray(array: {Instance})

	local orderedArray = {"default"}

	for i, instance in array do

		if instance.Name ~= "default" then

			local itemOrdered = false
			local frameNumber = tonumber(instance.Name)

			for x, number in orderedArray do

				if orderedArray[x + 1] then

					if tonumber(orderedArray[x + 1]) > frameNumber then

						table.insert(orderedArray, x + 1, `{frameNumber}`)
						itemOrdered = true
						break

					end

				end

			end

			if not itemOrdered then

				table.insert(orderedArray, `{frameNumber}`)

			end

		end

	end

	return orderedArray

end

local function preventCollisions(model: Model, weldPart: BasePart)
	
	local raycastResult
	repeat

		task.wait(1/10);

		if model:FindFirstChild("Humanoid") then

			local rayOrigin = model.HumanoidRootPart.CFrame
			local rayDirection = (model.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0,0,-5))).Position - model.HumanoidRootPart.Position
			local raycastParams = RaycastParams.new()
			raycastParams.CollisionGroup = "EnvironmentOnly"
			raycastResult = workspace:Blockcast(rayOrigin, Vector3.new(2, 2, 2), rayDirection, raycastParams)

		else

			break;

		end

	until raycastResult and raycastResult.Distance <= 5
	
	weldPart.Anchored = false
	
	print("collision detected with " .. raycastResult.Instance.Name)

end

function mAnimate2.animateCFrame(model: Model, animation)

	if animation then

		animation = animation:FindFirstChild("CFrame")
		--	Camera.CameraType = Enum.CameraType.Scriptable
		local FrameTime = 0
		local Connection

		local listInOrder = mathOrderArray(animation:GetChildren())
		local lastFrame = listInOrder[table.maxn(listInOrder)];

		local arrayNumber = 2
		local previousFrame = listInOrder[arrayNumber]
		local nextFrame = listInOrder[arrayNumber + 1];

		local lastCFrame = CFrame.new(Vector3.new(0,0,0))
		local amountToAdjust = CFrame.new(Vector3.new(0,0,0))

		local weldPart = script.MoonAnimateAnchor:Clone()
		local primaryPart = model.PrimaryPart;
		assert(primaryPart);

		weldPart.CFrame = primaryPart.CFrame;
		local startingPosition = weldPart.Position
		weldPart.Parent = model
		weldPart.RigidConstraint.Attachment0 = primaryPart:FindFirstChild("RootAttachment")
		coroutine.wrap(preventCollisions)(model, weldPart)
		local previousFrameCFrame = animation.default.Value
		local nextFrameCFrame = animation:FindFirstChild(nextFrame).Values:FindFirstChild("0").Value
		local originalHipHeight = weldPart.Parent.Humanoid.HipHeight
		
		Connection = RunService.RenderStepped:Connect(function(step: number)

			local NewDT = step * 60
			FrameTime += NewDT
			local currentFrame = FrameTime

			local humanoid = model:FindFirstChild("Humanoid");
			assert(humanoid and humanoid:IsA("Humanoid"));

			if currentFrame >= lastFrame and weldPart then

				Connection:Disconnect()
				weldPart:Destroy()
				humanoid.HipHeight = originalHipHeight

			else

				if currentFrame >= nextFrame then

					arrayNumber += 1
					previousFrame = listInOrder[arrayNumber]
					nextFrame = listInOrder[arrayNumber + 1];
					previousFrameCFrame = animation:FindFirstChild(previousFrame).Values:FindFirstChild("0").Value
					nextFrameCFrame = animation:FindFirstChild(nextFrame).Values:FindFirstChild("0").Value

				end

				local nextFramePercentage = (currentFrame - previousFrame) / (nextFrame - previousFrame)
				local resultPosition = previousFrameCFrame:Lerp(nextFrameCFrame, nextFramePercentage)
				local noYAxis = Vector3.new(1, 0, 1);
				local yAxis = Vector3.new(0, 1, 0);
				amountToAdjust = (
					CFrame.new(((resultPosition.Position * noYAxis) - (lastCFrame.Position * noYAxis))) 
					* (
						CFrame.new(
							Vector3.new(0, (((resultPosition.Position - (weldPart.Position - startingPosition)) * yAxis).Y), 0)
						)
					)
				)

				weldPart.CFrame = weldPart.CFrame * (amountToAdjust)
				weldPart.AssemblyLinearVelocity = (weldPart.CFrame.Rotation * amountToAdjust).Position * 5
				if amountToAdjust.Position.Y > 0.1 then

					weldPart.AssemblyLinearVelocity = weldPart.AssemblyLinearVelocity * Vector3.new(1, -1, 1);

				elseif amountToAdjust.Position.Y < 0.1 then

					humanoid.HipHeight = originalHipHeight + amountToAdjust.Position.Y;

				end

				lastCFrame = resultPosition

			end

		end)

	end

end

return mAnimate2
