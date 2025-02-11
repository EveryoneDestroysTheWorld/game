--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ContextActionService = game:GetService("ContextActionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local types = require(ReplicatedStorage.Client.Modules.types);

local id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
local name = "Strike-out Swipe";
local description = "";
local iconImage = "rbxassetid://131445376714174";

local StrikeOutSwipeClientAction = {
  id = id;
  name = name;
  description = description;
  iconImage = iconImage;
  __index = {
    id = id;
    name = name;
    iconImage = iconImage;
    description = description;
  } :: types.StrikeOutSwipeClientAction;
};

local player = Players.LocalPlayer;

function StrikeOutSwipeClientAction.new(): types.StrikeOutSwipeClientAction

  local remoteName = `{player.UserId}_{StrikeOutSwipeClientAction.id}`;
  local action = (setmetatable({}, StrikeOutSwipeClientAction) :: any) :: types.ChangeModesClientAction;
  action.remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);

  action.remoteFunction.OnClientInvoke = function()

    local character = player.Character;
    local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
    local animator = if humanoid then humanoid:FindFirstChild("Animator") else nil;

    if animator and animator:IsA("Animator") then

      local swingAnimation = Instance.new("Animation");
      swingAnimation.AnimationId = `rbxassetid://123556732066116`;
      local currentAnimationTrack = animator:LoadAnimation(swingAnimation);
      currentAnimationTrack.Looped = false;
      currentAnimationTrack:Play(0, 1, 8);

    end;

  end;

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    shortcutCharacter = "L";
    onActivate = function() 
    
      action:activate(true);
      action:activate(false);

    end;
    iconImage = iconImage;
  });

  local function checkInput(_, inputState: Enum.UserInputState, inputType: Enum.UserInputType)

    if inputState == Enum.UserInputState.Begin then

      action:activate(true);

    elseif inputState == Enum.UserInputState.End then

      action:activate(false);

    end;

  end;

  ContextActionService:BindAction("ActivateStrikeOutSwipe", checkInput, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.X);

  return action;

end

function StrikeOutSwipeClientAction.__index:activate(shouldCharge: boolean)

  self.remoteFunction:InvokeServer(shouldCharge);

end

function StrikeOutSwipeClientAction.__index:breakdown()
    
  HUDService:removeHUDButton("Action", self.id);
  ContextActionService:UnbindAction("ActivateStrikeOutSwipe");

end;

return StrikeOutSwipeClientAction;
