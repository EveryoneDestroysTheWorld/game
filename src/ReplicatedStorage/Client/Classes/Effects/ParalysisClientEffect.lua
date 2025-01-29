--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local getAnimator = require(ReplicatedStorage.Shared.Modules.getAnimator);
local types = require(ReplicatedStorage.Client.Modules.types);

local ParalysisClientEffect = {
  name = "Paralysis";
  id = script.Name:sub(1, script.Name:gsub("ClientEffect", ""):len());
  __index = {} :: types.ParalysisClientEffect;
}

function ParalysisClientEffect.new(properties: types.ParalysisClientEffectConstructorProperties): types.ParalysisClientEffect

  local overwrittenProperties: types.ParalysisClientEffectProperties = {
    name = ParalysisClientEffect.name;
    id = ParalysisClientEffect.id;
    uniqueID = properties.uniqueID;
    contestant = properties.contestant;
    events = {};
    frozenAnimations = {};
  };
  
  local effect = (setmetatable(overwrittenProperties, ParalysisClientEffect) :: unknown) :: types.ParalysisClientEffect;

  local remoteFunction = ReplicatedStorage.Shared.Functions.EffectFunctions:FindFirstChild(overwrittenProperties.uniqueID);
  if remoteFunction and remoteFunction:IsA("RemoteFunction") then

    remoteFunction.OnClientInvoke = function()

      effect:activate();

    end;

  end;

  return effect;

end;

local function toggleAnimateScript(character: Model, isEnabled: boolean): ()

  local animateScript = character:FindFirstChild("Animate");
  if animateScript and animateScript:IsA("LocalScript") then

    animateScript.Enabled = isEnabled;

  end;

end;

function ParalysisClientEffect.__index:activate()

  if self.contestant.character then

    toggleAnimateScript(self.contestant.character, false);
    
    local humanoid = self.contestant.character:FindFirstChild("Humanoid") :: Humanoid?;
    if humanoid then

      humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll);

    end;

    local animator = getAnimator(self.contestant.character);

    if animator then

      for _, track in animator:GetPlayingAnimationTracks() do

        self.frozenAnimations[track] = track.Speed;
        track:AdjustSpeed(0);

      end;

    end;

  end;

end;

function ParalysisClientEffect.__index:deactivate()

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