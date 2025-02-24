--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ContextActionService = game:GetService("ContextActionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);



local StrikeOutSwipeClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Strike-out Swipe";
  description = "";
  iconImage = "rbxassetid://131445376714174";
};

local player = Players.LocalPlayer;

function StrikeOutSwipeClientAction.new(): SharedTypes.StrikeOutSwipeClientAction

  local remoteName = `{player.UserId}_{StrikeOutSwipeClientAction.id}`;
  local remoteEvent = ReplicatedStorage.Shared.Events.ActionEvents:WaitForChild(remoteName);
  local action: SharedTypes.StrikeOutSwipeClientAction = {
    id = StrikeOutSwipeClientAction.id;
    name = StrikeOutSwipeClientAction.name;
    iconImage = StrikeOutSwipeClientAction.iconImage;
    description = StrikeOutSwipeClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    remoteEvent = remoteEvent;
    attributes = {
      isCharging = false;
    };
    activate = function(self: SharedTypes.StrikeOutSwipeClientAction)

      local shouldCharge = self.attributes.isCharging;
      self.attributes.isCharging = false;
      self.remoteFunction:InvokeServer(shouldCharge);

    end;
    breakdown = function(self: SharedTypes.StrikeOutSwipeClientAction)
    
      HUDService:removeHUDButton("Action", self.id);
      ContextActionService:UnbindAction("ActivateStrikeOutSwipe");
    
    end;
  }

  action.remoteFunction.OnClientInvoke = function(shouldCharge: boolean): ()

    local character = player.Character;
    local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
    local animator = if humanoid then humanoid:FindFirstChild("Animator") else nil;

    if animator and animator:IsA("Animator") then

      if action.attributes.swingAnimation then

        action.attributes.swingAnimation:Stop(0);

      end;

      local swingAnimation = Instance.new("Animation");
      swingAnimation.AnimationId = `rbxassetid://123556732066116`;
      local currentAnimationTrack = animator:LoadAnimation(swingAnimation);
      currentAnimationTrack.Looped = false;
      currentAnimationTrack:Play(if shouldCharge then 1 else 0, 1, if shouldCharge then 0 else 8);
      action.attributes.swingAnimation = currentAnimationTrack;

    end;

  end;

  local isExhausted = false;
  remoteEvent.OnClientEvent:Connect(function()
  
    isExhausted = true;

  end);

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    shortcutCharacter = "L";
    onActivate = function() 
    
      action.attributes.isCharging = true;
      action:activate();
      action:activate();

    end;
    iconImage = action.iconImage;
  });

  local function checkInput(_, inputState: Enum.UserInputState, inputType: Enum.UserInputType)

    if inputState == Enum.UserInputState.Begin then

      action.attributes.isCharging = true;
      action:activate();

    elseif inputState == Enum.UserInputState.End then

      if isExhausted then

        isExhausted = false;
        
      else 
        
        action:activate();

      end;

    end;

  end;

  ContextActionService:BindAction("ActivateStrikeOutSwipe", checkInput, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.X);

  return action;

end

return StrikeOutSwipeClientAction;
