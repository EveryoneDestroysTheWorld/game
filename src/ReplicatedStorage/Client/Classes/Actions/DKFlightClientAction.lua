--!strict
-- Writer: Hati ---- Heavily modified edit of ExplosivePunch
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(script.Parent.Parent.Parent.ReactComponents.HUDButton);
type ClientAction = ClientAction.ClientAction;

local TakeFlightAction = {
	ID = 6;
	iconImage = "rbxassetid://17771917538";
	name = "Take Flight";
	description = "You are great at flying! I'm suprised those wings can carry you.";
};

local activeState = false
local function flightControls()

	local flightControlsConnect
	flightControlsConnect = Players.LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)

		if child.Name == "LinearVelocity" then

			flightControlsConnect:Disconnect()
			activeState = true
			local linearVelocity = Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("LinearVelocity")
			local humanoid = Players.LocalPlayer.Character.Humanoid
			-- this waits for the controls to be enabled by the server
			linearVelocity:SetAttribute("PlayerControls", false)
			local connection
			local connection2
			connection = linearVelocity.AttributeChanged:Connect(function()

				connection:Disconnect()
				connection = linearVelocity.AttributeChanged:Connect(function()

					connection:Disconnect()
					connection2:Disconnect()
					activeState = false
					flightControls()

				end)

				local verticalVelocity = 0
				connection2 = RunService.RenderStepped:Connect(function(step)

					verticalVelocity = if humanoid.Jump == true then 0.8 else 0;
					local value = (humanoid.MoveDirection) + Vector3.new(0,verticalVelocity,0)
					local tween = TweenService:Create(linearVelocity, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {VectorVelocity = value * 20})
					tween:Play()

				end)

			end)

		end

	end)

end

function TakeFlightAction.new(): ClientAction

	local remoteName: string;

	local function breakdown(self: ClientAction)

		ContextActionService:UnbindAction("ActivateTakeFlight");

	end;

	local allowedToToggle = true
	local function activate(self: ClientAction)

		ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();
		flightControls()
		allowedToToggle = false
		task.wait(1)
		allowedToToggle = true

	end;

	local function initialize(self: ClientAction)

		local player = Players.LocalPlayer;

		if player.Character then
			
			flightControls()
			
		end

		ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
			type = "Action";
			key = self.ID;
			onActivate = function()

				self:activate();
		
			end;
			shortcutCharacter = "L";
			iconImage = "rbxassetid://17771917538";
		}));
		
		remoteName = `{player.UserId}_{self.ID}`;
		local debounce = false
		local function checkJump(_, inputState: Enum.UserInputState)
			if inputState == Enum.UserInputState.Begin and allowedToToggle == true then
				if debounce == false then
					debounce = true
					if activeState == false then
						task.wait(0.4)
						if debounce and Players.LocalPlayer.Character.Humanoid.Jump == true  then
							debounce = false
							self:activate();
						end
					end
				else
					debounce = false
					self:activate();
				end
		
			end;
		
		end;
		
		ContextActionService:BindActionAtPriority("ActivateTakeFlight", checkJump, false, 2, Enum.KeyCode.Space);

	end;

	return ClientAction.new({
		ID = TakeFlightAction.ID;
		iconImage = TakeFlightAction.iconImage;
		name = TakeFlightAction.name;
		description = TakeFlightAction.description;
		activate = activate;
		breakdown = breakdown;
		initialize = initialize;
	});

end

return TakeFlightAction;