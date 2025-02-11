--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local function playSwingAnimation(action: types.StrikeOutSwipeServerAction, shouldCharge: boolean): ()

  local player = action.contestant.player;
  if player and action.remoteFunction then

    action.remoteFunction:InvokeClient(player, shouldCharge);

  else
    
    local character = action.contestant.character;
    local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
    local animator = if humanoid then humanoid:FindFirstChild("Animator") else nil;

    if animator and animator:IsA("Animator") then

      if action.swingAnimation then

        action.swingAnimation:Stop(0);

      end;

      local swingAnimation = Instance.new("Animation");
      swingAnimation.AnimationId = `rbxassetid://123556732066116`;
      local currentAnimationTrack = animator:LoadAnimation(swingAnimation);
      currentAnimationTrack.Looped = false;
      currentAnimationTrack:Play(if shouldCharge then 1 else 0, 1, if shouldCharge then 0 else 8);
      action.swingAnimation = currentAnimationTrack;

    end;

  end;

end;

return playSwingAnimation;