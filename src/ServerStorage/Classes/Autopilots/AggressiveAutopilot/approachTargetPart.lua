--!strict

local function approachTargetPart(character: Model, targetPart: BasePart, minimumDistance: number, goalDistance: number)

  local userPrimaryPart = character.PrimaryPart;
  if not userPrimaryPart then return false end;

  if (targetPart.Position - userPrimaryPart.Position).Magnitude <= minimumDistance then

    return true;

  else

    local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
    if not humanoid or not humanoid:IsA("Humanoid") then 
      
      return false;

    end;

    humanoid:MoveTo(targetPart.Position, targetPart);

  end;

  return false;

end;

return approachTargetPart;