--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");

local CameraService = require(ReplicatedStorage.Client.Modules.CameraService);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);

local Crosshairs = require(script.Components.Crosshairs);

local camera = workspace.CurrentCamera;
local player = Players.LocalPlayer;
local character = player.Character;

player.CharacterAdded:Connect(function()
  
  character = player.Character;
  
end);

local xAngle = 0;
local yAngle = 0;
local cameraOffset = Vector3.new(5,2,15);
RunService.RenderStepped:Connect(function()
  
  if not character then
    
    return;
    
  end

  UserInputService.MouseBehavior = if CameraService.lockMouse then Enum.MouseBehavior.LockCenter else Enum.MouseBehavior.Default;
  UserInputService.MouseIconEnabled = not CameraService.lockMouse;
  
  if CameraService.lockMouse then

    local primaryPart = character.PrimaryPart;
    
    local head = character:FindFirstChild("Head");
    if not primaryPart or not head then
      return;
    end
    
    local startCFrame = CFrame.new((primaryPart.CFrame.Position + Vector3.new(0,2,0))) * CFrame.Angles(0, math.rad(xAngle), 0) * CFrame.Angles(math.rad(yAngle), 0, 0);
    local cameraCFrame = startCFrame + startCFrame:VectorToWorldSpace(Vector3.new(cameraOffset.X, cameraOffset.Y, cameraOffset.Z))
    local cameraFocus = startCFrame:ToWorldSpace(CFrame.new(cameraOffset.X, cameraOffset.Y, -10000));
    camera.CFrame = CFrame.new(cameraCFrame.Position, cameraFocus.Position);
    
    local centerVector = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2  - (game:GetService("GuiService"):GetGuiInset().Y/2));
    local unitRay = camera:ViewportPointToRay(centerVector.X, centerVector.Y);
    local parts = {};
    for _, part in character:GetDescendants() do
      
      if part:IsA("BasePart") then
        
        table.insert(parts, part);
        
      end
      
    end
    
    local raycastParams = RaycastParams.new();
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude;
    raycastParams.FilterDescendantsInstances = parts;
    local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams);
    local position = if raycastResult then raycastResult.Position else unitRay.Direction * 1000;
    
    local goalCFrame = CFrame.new(primaryPart.Position, position);
    local _, rY = goalCFrame:ToOrientation();
    primaryPart.CFrame = CFrame.fromOrientation(0, rY, 0) + primaryPart.Position;

  end;
  
end);

UserInputService.InputChanged:Connect(function(input: InputObject)
  if input.UserInputType == Enum.UserInputType.MouseMovement then
    xAngle -= input.Delta.X * 0.4
    --Clamp the vertical axis so it doesn't go upside down or glitch.
    yAngle = math.clamp(yAngle-input.Delta.Y * 0.4, -80, 30)
  end
end)

UserInputService.TouchMoved:Connect(function(input: InputObject)

  if input ~= CameraService.virtualControllerTouch then
  
    local touchSensitivityLevel = 1.2;
    
    xAngle -= input.Delta.X * touchSensitivityLevel;
    --Clamp the vertical axis so it doesn't go upside down or glitch.
    yAngle = math.clamp(yAngle-input.Delta.Y * touchSensitivityLevel,-80,30)

  end;
  
end)

local function initializeTargetGUI()

  camera.CameraType = Enum.CameraType.Scriptable;
  camera.FieldOfView = 80;

  local targetGUI = script.TargetGUI:Clone();
  targetGUI.Parent = player:WaitForChild("PlayerGui");

  local targetIndicatorRoot = ReactRoblox.createRoot(targetGUI);
  targetIndicatorRoot:render(React.createElement(Crosshairs));

end;

local round = ClientRound.fromServerRound();
if round.status == "Active" then

  initializeTargetGUI();

else

  round.onStarted:Once(initializeTargetGUI);

end