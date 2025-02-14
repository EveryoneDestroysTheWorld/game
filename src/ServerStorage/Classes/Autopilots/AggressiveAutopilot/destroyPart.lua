--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local findAction = require(script.Parent.findAction);

local function destroyPart(autopilotContestant: types.ServerContestant, targetPart: BasePart)
  
  local character = autopilotContestant.character;
  local userPrimaryPart = if character then character.PrimaryPart else nil;
  local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
  if not userPrimaryPart or not character or not humanoid or not humanoid:IsA("Humanoid") then return end;

  local goalDistance = 5;
  if (targetPart.Position - userPrimaryPart.Position).Magnitude <= goalDistance then

    local archetype = autopilotContestant.archetype;
    if archetype then

      local rocketFeetAction = findAction(archetype.actions, "RocketFeet");
      if rocketFeetAction then

        rocketFeetAction:activate();

      end;

    end;

  else

    humanoid:MoveTo(targetPart.Position, targetPart);

  end;

end;

return destroyPart;