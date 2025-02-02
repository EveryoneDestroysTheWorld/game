--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local getAnimator = require(ReplicatedStorage.Shared.Modules.getAnimator);

local character = script.Parent;

ReplicatedStorage.Shared.Functions.ChangeHumanoidState.OnClientInvoke = function(humanoidState: Enum.HumanoidStateType)

  local humanoid = character:FindFirstChild("Humanoid");
  assert(humanoid and humanoid:IsA("Humanoid"));

  humanoid:ChangeState(humanoidState);

end;

ReplicatedStorage.Shared.Functions.ToggleAnimateScript.OnClientInvoke = function(shouldEnable: boolean?)

  local animateScript = character:FindFirstChild("Animate");
  if animateScript and animateScript:IsA("LocalScript") then

    animateScript.Enabled = if typeof(shouldEnable) == "boolean" then shouldEnable else not animateScript.Enabled;

    if not animateScript.Enabled then

      local animator = getAnimator(character);

      if animator then

        for _, track in animator:GetPlayingAnimationTracks() do

          track:Stop();

        end;

      end;

    end;

  end;

end;