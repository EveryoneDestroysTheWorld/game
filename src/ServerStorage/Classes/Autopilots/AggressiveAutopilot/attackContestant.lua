--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local findAction = require(script.Parent.findAction);

local function attackContestant(autopilotContestant: types.ServerContestant, targetContestant: types.ServerContestant)
  
  local character = autopilotContestant.character;
  local userPrimaryPart = if character then character.PrimaryPart else nil;
  local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
  if not userPrimaryPart or not character or not humanoid or not humanoid:IsA("Humanoid") then return end;

  local targetCharacter = if targetContestant then targetContestant.character else nil;
  local targetPrimaryPart = if targetCharacter then targetCharacter.PrimaryPart else nil;
  if targetContestant and targetCharacter and targetPrimaryPart then

    local goalDistance = 5;
    if (targetPrimaryPart.Position - userPrimaryPart.Position).Magnitude <= goalDistance then

      local archetype = autopilotContestant.archetype;
      if archetype then

        local explosivePunchAction = findAction(archetype.actions, "ExplosivePunch");
        if explosivePunchAction then

          explosivePunchAction:activate();

        end;

      end;

    else

      humanoid:MoveTo(targetPrimaryPart.Position, targetPrimaryPart);

    end;

  end;

end;

return attackContestant;