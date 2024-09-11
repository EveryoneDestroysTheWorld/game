--!strict
-- Writer: Hati ---- Heavily modified edit of ExplosivePunch
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local InsertService = game:GetService("InsertService")
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ActionButton = require(script.Parent.Parent.Parent.ReactComponents.ActionButton);
type ClientAction = ClientAction.ClientAction;

local DiveBombAction = {
	ID = 7;
	iconImage = "rbxassetid://17771917538";
	name = "Dive Bomb";
	description = "Rush to target location, stunning enemies in an area and dealing damage to EVERYONE nearby.";
};
local function waitForServerResponse(coordinateData)
	local connection
	connection = Players.LocalPlayer.ChildAdded:Connect(function(child)
if child:IsA("RemoteEvent") and child.Name == "GetData" then
	--data request recieved from server
	connection:Disconnect()
child:FireServer(coordinateData)
--sent data back to server
end
end)
end
local playerDisplay = {}
local function displayTarget(state)
	if state == "Start" then
		playerDisplay["obj"] = ReplicatedStorage.Client.InGameDisplayObjects.DiveBombIndicator:Clone()
		playerDisplay["obj"].Root.Position = Players.LocalPlayer:GetMouse().Hit.Position + Vector3.new(0,0.5,0)
			playerDisplay["obj"].Parent = workspace.Terrain
			playerDisplay["obj"]:FindFirstChild("Beam", true).Attachment1 = Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
		playerDisplay["con"] = RunService.Stepped:Connect(function()
				playerDisplay["obj"].Root.Position = Players.LocalPlayer:GetMouse().Hit.Position + Vector3.new(0,0.5,0)
		end)
		
	else
	playerDisplay["obj"]:Destroy()
	playerDisplay["con"]:Disconnect()
	end

end
function DiveBombAction.new(): ClientAction
	print(DiveBombAction.ID)
	local player = Players.LocalPlayer;
	local remoteName: string;

	local function breakdown(self: ClientAction)

		ContextActionService:UnbindAction("ActivateDiveBomb");

	end;

	local function activate(self: ClientAction)
		waitForServerResponse(player:GetMouse().Hit.Position)
		ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();
	end;

	local action = ClientAction.new({
		ID = DiveBombAction.ID;
		iconImage = DiveBombAction.iconImage;
		name = DiveBombAction.name;
		description = DiveBombAction.description;
		activate = activate;
		breakdown = breakdown;
	});
	local allowedToToggle = true
	ReplicatedStorage.Client.Functions.AddActionButton:Invoke(React.createElement(ActionButton, {
		onActivate = function()
			action:activate("Input");
		end;
		shortcutCharacter = "1";
		iconImage = "rbxassetid://17771917538";
	}));

	remoteName = `{player.UserId}_{action.ID}`;
	local debounce = false
	local function checkJump(_, inputState: Enum.UserInputState)
		if inputState == Enum.UserInputState.Begin then
			displayTarget("Start")
		elseif inputState == Enum.UserInputState.End then
			displayTarget("Release")
			action:activate();
		end
	end;

	ContextActionService:BindActionAtPriority("ActivateDiveBomb", checkJump, false, 2, Enum.KeyCode.One);

	return action;

end

return DiveBombAction;