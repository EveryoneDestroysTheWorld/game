--!strict
-- Programmer: Hati (hati_bati)
-- © 2024 Beastslash LLC


local mAnimate2 = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.Camera
local TweenService = game:GetService("TweenService")
local modules = ReplicatedStorage:WaitForChild("Modules")
--local movement = require(modules.Movement)
  
local modules = ReplicatedStorage:WaitForChild("Modules")
--local mAnimate2backup = require(modules.mAnimate2backup)



local function mathOrderArray(array)
	local orderedArray = {"default"}
	for i, frameNumber in ipairs(array) do
		if frameNumber.Name ~= "default" then
			local itemOrdered = false
			frameNumber = tonumber(frameNumber.Name)
			for i, number in ipairs(orderedArray) do
				if orderedArray[i+1] then
					if orderedArray[i+1] > frameNumber then
						table.insert(orderedArray, i+1, frameNumber)
						itemOrdered = true
						break
					end

				end

			end
			if itemOrdered == false then
				table.insert(orderedArray, frameNumber)
			end
		end
	end
	return orderedArray
end
local function preventCollisions(model, weldPart)
	
	local raycastResult
	repeat
		task.wait(1/10)
		if model:FindFirstChild("Humanoid") then
			local rayOrigin = model.HumanoidRootPart.CFrame
			local rayDirection = (model.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0,0,-5))).Position - model.HumanoidRootPart.Position
			local raycastParams = RaycastParams.new()
			raycastParams.CollisionGroup = "EnviromentOnly"
			raycastResult = workspace:Blockcast(rayOrigin, Vector3.new(2,2,2), rayDirection, raycastParams)
		else
			break
		end
	until raycastResult and raycastResult.Distance <= 5
	weldPart.Anchored = false
	print("collision detected with " .. raycastResult.Instance.Name)
	--	print("WeldUnachored")
end


function mAnimate2.animateCFrame(model, animation)
	if animation then
		animation = animation:FindFirstChild("CFrame")
		--	Camera.CameraType = Enum.CameraType.Scriptable
		local FrameTime = 0
		local Connection
		local previousFrameCFrame = CFrame.new(Vector3.new(0,0,0))

		local listInOrder = mathOrderArray(animation:GetChildren())
		local lastFrame = listInOrder[table.maxn(listInOrder)]
		local arrayNumber = 2
		local previousFrame = listInOrder[arrayNumber]
		local nextFrame = listInOrder[arrayNumber+1]
		local lastCFrame = CFrame.new(Vector3.new(0,0,0))
		local amountToAdjust = CFrame.new(Vector3.new(0,0,0))

		local weldPart = script.MoonAnimateAnchor:Clone()
	--				weldPart.Anchored = true
		--model.HumanoidRootPart.Anchored = true
		weldPart.CFrame = model.HumanoidRootPart.CFrame
		local startingPosition = weldPart.Position
		weldPart.Parent = model
		weldPart.RigidConstraint.Attachment0 = model.HumanoidRootPart.RootAttachment
		coroutine.wrap(preventCollisions)(model, weldPart)
		local previousFrameCFrame = animation.default.Value
		local nextFrameCFrame = animation:FindFirstChild(nextFrame).Values:FindFirstChild("0").Value
		local originalHipHeight = weldPart.Parent.Humanoid.HipHeight
		
		
		
		
		
		Connection = RunService.RenderStepped:Connect(function(step)

			local NewDT = step * 60
			FrameTime += NewDT
			local currentFrame = FrameTime

			if currentFrame >= lastFrame and weldPart then
				Connection:Disconnect()
				weldPart:Destroy()
				model.Humanoid.HipHeight = originalHipHeight
			else
				if currentFrame >= nextFrame then
					arrayNumber += 1
					previousFrame = listInOrder[arrayNumber]
					nextFrame = listInOrder[arrayNumber+1]
					previousFrameCFrame = animation:FindFirstChild(previousFrame).Values:FindFirstChild("0").Value
					nextFrameCFrame = animation:FindFirstChild(nextFrame).Values:FindFirstChild("0").Value
				end


				local nextframePercentage = (currentFrame
					- previousFrame) 
					/ (nextFrame 
						- previousFrame)

				local resultPosition = previousFrameCFrame:Lerp(nextFrameCFrame, nextframePercentage)
				local noYaxis = Vector3.new(1,0,1)
				local Yaxis = Vector3.new(0,1,0)
				amountToAdjust =CFrame.new(((resultPosition.Position * noYaxis) - 
					(lastCFrame.Position * noYaxis) ))


				amountToAdjust *= CFrame.new(
					Vector3.new(0,(((resultPosition.Position  - (weldPart.Position - startingPosition))*Yaxis).Y),0)
				)

				local x,y,z = resultPosition:ToEulerAngles()
				weldPart.CFrame = weldPart.CFrame * (amountToAdjust)
				weldPart.AssemblyLinearVelocity = (weldPart.CFrame.Rotation * amountToAdjust).Position * 5
				if amountToAdjust.Position.Y > 0.1 then
					weldPart.AssemblyLinearVelocity = weldPart.AssemblyLinearVelocity * Vector3.new(1, -1, 1)
				elseif amountToAdjust.Position.Y < 0.1 then
					model.Humanoid.HipHeight = originalHipHeight + amountToAdjust.Position.Y
				end


				lastCFrame = resultPosition

			end
		end)
	end
end




return mAnimate2
