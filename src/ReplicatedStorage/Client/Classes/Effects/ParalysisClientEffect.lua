--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local getAnimator = require(ReplicatedStorage.Shared.Modules.getAnimator);
local types = require(ReplicatedStorage.Client.Classes.types);

local ParalysisClientEffect = {
  name = "Paralysis";
  id = script.Name:sub(1, script.Name:gsub("ClientEffect", ""):len());
  __index = {} :: types.ParalysisClientEffect;
}

function ParalysisClientEffect.new(properties: types.ParalysisClientEffectConstructorProperties): types.ParalysisClientEffect

  local effect: types.ParalysisClientEffectProperties = {
    name = ParalysisClientEffect.name;
    id = ParalysisClientEffect.id;
    contestant = properties.contestant;
    frozenAnimations = {};
  };

  return (setmetatable(effect, ParalysisClientEffect) :: unknown) :: types.ParalysisClientEffect

end;

local function toggleAnimateScript(character: Model, isEnabled: boolean): ()

  print(5);
  local animateScript = character:FindFirstChild("Animate");
  if animateScript and animateScript:IsA("LocalScript") then

    print(6);
    animateScript.Enabled = isEnabled;

  end;

end;

function ParalysisClientEffect.__index:activate()

  print(1);
  print(self.contestant)
  if self.contestant.character then

    print(2);
    toggleAnimateScript(self.contestant.character, false);

    local animator = getAnimator(self.contestant.character);

    if animator then

      print(3);
      for _, track in animator:GetPlayingAnimationTracks() do

        print(4);
        self.frozenAnimations[track] = track.Speed;
        track:AdjustSpeed(0);

      end;

    end;

  end;

end;

function ParalysisClientEffect.__index:deactivate(contestant: types.ClientContestant)

  if self.contestant.character then

    toggleAnimateScript(self.contestant.character, true);

    local animator = getAnimator(self.contestant.character);
    if animator then

      for track, normalSpeed in self.frozenAnimations do

        track:AdjustSpeed(normalSpeed);

      end;

      self.frozenAnimations = {};

    end;

  end;

end;

return ParalysisClientEffect;