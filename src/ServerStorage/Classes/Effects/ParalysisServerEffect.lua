--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local HttpService = game:GetService("HttpService");

local types = require(ServerStorage.Classes.types);
local getAnimator = require(ReplicatedStorage.Shared.Modules.getAnimator);

local ParalysisServerEffect = {
  name = "Paralysis";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.ParalysisServerEffect;
}

function ParalysisServerEffect.new(properties: types.ParalysisServerEffectConstructorProperties): types.ParalysisServerEffect

  local effect: types.ParalysisServerEffectProperties = {
    name = ParalysisServerEffect.name;
    id = ParalysisServerEffect.id;
    uniqueID = HttpService:GenerateGUID(false);
    contestant = properties.contestant;
    weight = {
      walkSpeed = 0;
      weight = math.huge;
    };
    frozenAnimations = {};
  };

  return (setmetatable(effect, ParalysisServerEffect) :: unknown) :: types.ParalysisServerEffect

end;

local function togglePlatformStand(character: Model?, shouldEnable: boolean)

  if character then

    local humanoid = character:FindFirstChild("Humanoid");
    if humanoid and humanoid:IsA("Humanoid") then

      humanoid.PlatformStand = shouldEnable;

    end;

  end;

end;

function ParalysisServerEffect.__index:activate()

  self.contestant:addWalkSpeedWeight(self.weight);

  if self.contestant.player then

    -- Handle the animations on the client.
    local remoteFunction = Instance.new("RemoteFunction");
    remoteFunction.Name = self.uniqueID;
    remoteFunction.Parent = ReplicatedStorage.Shared.Functions.EffectFunctions;
    ReplicatedStorage.Shared.Functions.InitializeEffect:InvokeClient(self.contestant.player, self.id, self.uniqueID, true);
    remoteFunction:InvokeClient(self.contestant.player);

  else
    
    -- Handle the animations on the server.
    local animator = getAnimator(self.contestant.character);

    if animator then

      for _, track in animator:GetPlayingAnimationTracks() do

        self.frozenAnimations[track] = track.Speed;
        track:AdjustSpeed(0);

      end;

    end;

  end;

  -- Tip the player.
  togglePlatformStand(self.contestant.character, true);

end;

function ParalysisServerEffect.__index:deactivate(contestant: types.ServerContestant)

  contestant:removeWalkSpeedWeight(self.weight);

  if self.contestant.player then

    ReplicatedStorage.Shared.Functions.InitializeEffect:InvokeClient(self.contestant.player, self.id, self.uniqueID, false);

  else

    local animator = getAnimator(self.contestant.character);
    if animator then

      for track, normalSpeed in self.frozenAnimations do

        track:AdjustSpeed(normalSpeed);

      end;

      self.frozenAnimations = {};

    end;

  end;

  togglePlatformStand(self.contestant.character, false);

end;

return ParalysisServerEffect;