--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");

local types = require(ReplicatedStorage.Client.Modules.types);

local RocketFeetClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Rocket Feet";
  description = "Fly, touch the sky!";
  iconImage = "rbxassetid://18464513809";
  __index = {} :: types.RocketFeetClientAction;
};

function RocketFeetClientAction.new(): types.RocketFeetClientAction

  local player = Players.LocalPlayer;
  local remoteName = `{player.UserId}_{RocketFeetClientAction.id}`

  local overwrittenProperties = {
    id = RocketFeetClientAction.id;
    name = RocketFeetClientAction.name;
    iconImage = RocketFeetClientAction.iconImage;
    description = RocketFeetClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName);
  }

  local action = (setmetatable(overwrittenProperties, RocketFeetClientAction) :: any) :: types.RocketFeetClientAction;

  local function checkJump(_, inputState: Enum.UserInputState)

    if inputState == Enum.UserInputState.Begin then

      local humanoid = player.Character:FindFirstChild("Humanoid") :: Humanoid;
      if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        
        action:activate();

      end;
    
    end;

  end;

  ContextActionService:BindActionAtPriority("ActivateRocketFeet", checkJump, false, 2, Enum.KeyCode.Space, Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonX);

  if UserInputService.TouchEnabled then

    local jumpButton = player.PlayerGui:FindFirstChild("TouchGui"):FindFirstChild("TouchControlFrame"):FindFirstChild("JumpButton");
    if jumpButton then

      action.jumpButtonClickEvent = jumpButton.MouseButton1Click:Connect(function()
      
        action:activate();

      end);

    end;

  end;

  local remoteEvent = ReplicatedStorage.Shared.Events.ActionEvents:WaitForChild(remoteName);
  assert(remoteEvent:IsA("RemoteEvent"));

  remoteEvent.OnClientEvent:Connect(function(isRocketFeetEnabled: boolean)

    local playerControls = (require(player.PlayerScripts.PlayerModule) :: any):GetControls();
    if isRocketFeetEnabled then

      -- Disable default controls.
      playerControls:Disable();

      -- Send control info to the server.
      if action.cFrameEvent then

        action.cFrameEvent:Disconnect();
        
      end;

      action.cFrameEvent = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
      
        local cameraRotationX, cameraRotationY, cameraRotationZ = workspace.CurrentCamera.CFrame:ToEulerAnglesXYZ();
        local cameraOrientation = CFrame.new(player.Character.HumanoidRootPart.CFrame.Position) * CFrame.Angles(cameraRotationX, cameraRotationY, cameraRotationZ);
        remoteEvent:FireServer({cameraOrientation = cameraOrientation});

      end);

      local currentDirections = {};
      local function handleAction(actionName, inputState: Enum.UserInputState, inputObject: InputObject)

        local direction = ({W = "forward"; A = "left"; S = "backward"; D = "right"})[inputObject.KeyCode.Name];
        if direction then
  
          -- Move the player.
          local directionVelocity = player.Character.HumanoidRootPart.Direction;
          local forceX = if direction == "left" or direction == "right" then 0 else directionVelocity.VectorVelocity.X;
          local forceZ = if direction == "forward" or direction == "backward" then 0 else directionVelocity.VectorVelocity.Z;
          if inputState == Enum.UserInputState.Begin then
  
            currentDirections[direction] = true;
  
            forceX = if currentDirections.left then -100 elseif currentDirections.right then 100 else 0;
            forceZ = if currentDirections.forward then -100 elseif currentDirections.backward then 100 else 0; 
  
          else
  
            currentDirections[direction] = nil;
  
          end
  
          remoteEvent:FireServer({vectorVelocity = Vector3.new(forceX, 0, forceZ)} :: any);
  
        end;

      end;

      ContextActionService:BindAction("FlyingDirection", handleAction, false, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D)

    else

      -- Re-enable normal controls.
      if action.cFrameEvent then

        action.cFrameEvent:Disconnect();

      end;

      ContextActionService:UnbindAction("FlyingDirection");
      playerControls:Enable();

    end;

  end);

  return action;

end

function RocketFeetClientAction.__index:activate()

  self.remoteFunction:InvokeServer();

end

function RocketFeetClientAction.__index:breakdown()

  ContextActionService:UnbindAction("ActivateRocketFeet");

  if self.cFrameEvent then

    self.cFrameEvent:Disconnect();

  end;

  if self.jumpButtonClickEvent then

    self.jumpButtonClickEvent:Disconnect();

  end
  
  ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

end

return RocketFeetClientAction;
