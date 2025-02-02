--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

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
    remoteFunction = ReplicatedStorage.Shared.Functions.EffectFunctions:FindFirstChild(properties.uniqueID);
  };
  
  local effect = (setmetatable(overwrittenProperties, ParalysisClientEffect) :: unknown) :: types.ParalysisClientEffect;

  assert(effect.remoteFunction and effect.remoteFunction:IsA("RemoteFunction"));
  effect.remoteFunction.OnClientInvoke = function()

    effect:activate();

  end;

  return effect;

end;

function ParalysisClientEffect.__index:activate()


end;

function ParalysisClientEffect.__index:deactivate()
  

end;

return ParalysisClientEffect;