--!strict

local function getAnimator(character: Model?): Animator?

  local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
  local animator = if humanoid then humanoid:FindFirstChild("Animator") else nil;
  if animator and animator:IsA("Animator") then

    return animator;

  end

  return;

end;

return getAnimator;