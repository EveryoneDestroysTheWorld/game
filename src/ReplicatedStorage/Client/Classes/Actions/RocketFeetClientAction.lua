--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");
local ClientAction = require(script.Parent.Parent.ClientAction);
type ClientAction = ClientAction.ClientAction;

local DetachLimbAction = {
  ID = 4;
  name = "Rocket Feet";
  description = "Fly, touch the sky!";
};

function DetachLimbAction.new(): ClientAction

  local action: ClientAction;

  local jumpButtonClickEvent;
  local remoteEventConnection;

  local function breakdown(self: ClientAction)

    ContextActionService:UnbindAction("ActivateRocketFeet");
    if jumpButtonClickEvent then

      jumpButtonClickEvent:Disconnect();

    end

    if remoteEventConnection then

      remoteEventConnection:Disconnect();

    end;

  end;

  local player = Players.LocalPlayer;
  local remoteName: string;

  local function activate(self: ClientAction)

    ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();

  end;

  action = ClientAction.new({
    ID = DetachLimbAction.ID;
    name = DetachLimbAction.name;
    description = DetachLimbAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  remoteName = `{player.UserId}_{action.ID}`;

  local lastJumpTime = 0;
  local function checkJump(_, inputState: Enum.UserInputState)

    if inputState == Enum.UserInputState.Begin then

      if lastJumpTime > DateTime.now().UnixTimestampMillis - 500 then
          
        action:activate();

      end;

      lastJumpTime = DateTime.now().UnixTimestampMillis;
    
    end;

  end;

  ContextActionService:BindActionAtPriority("ActivateRocketFeet", checkJump, false, 2, Enum.KeyCode.Space, Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonX);

  if UserInputService.TouchEnabled then

    local jumpButton = Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui"):FindFirstChild("TouchControlFrame"):FindFirstChild("JumpButton");
    if jumpButton then

      jumpButtonClickEvent = jumpButton.MouseButton1Click:Connect(function()
      
        action:activate();

      end);

    end;

  end;

  local ActionEvents = ReplicatedStorage.Shared.Events.ActionEvents;
  local actionEventAdded: RBXScriptConnection;
  actionEventAdded = ActionEvents.ChildAdded:Connect(function(child)
  
    if child:IsA("RemoteEvent") and child.Name == remoteName then

      actionEventAdded:Disconnect();

      local cFrameEvent;
      remoteEventConnection = child.OnClientEvent:Connect(function(isRocketFeetEnabled: boolean)
  
        local playerControls = (require(player.PlayerScripts.PlayerModule) :: any):GetControls();
        if isRocketFeetEnabled then
  
          -- Disable default controls.
          playerControls:Disable();
  
          -- Send control info to the server.
          cFrameEvent = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
          
            local cameraRotationX, cameraRotationY, cameraRotationZ = workspace.CurrentCamera.CFrame:ToEulerAnglesXYZ();
            local cameraOrientation = CFrame.new(player.Character.HumanoidRootPart.CFrame.Position) * CFrame.Angles(cameraRotationX, cameraRotationY, cameraRotationZ);
            child:FireServer({cameraOrientation = cameraOrientation});
  
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
      
              child:FireServer({vectorVelocity = Vector3.new(forceX, 0, forceZ)} :: any);
      
            end;
  
          end;
  
          ContextActionService:BindAction("FlyingDirection", handleAction, false, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D)
  
        else
  
          -- Re-enable normal controls.
          if cFrameEvent then
  
            cFrameEvent:Disconnect();
  
          end;
          ContextActionService:UnbindAction("FlyingDirection");
          playerControls:Enable();
  
        end;
  
      end);

    end;

  end);

  return action;

end

return DetachLimbAction;
