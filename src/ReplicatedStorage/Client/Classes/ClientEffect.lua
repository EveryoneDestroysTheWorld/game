--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local types = require(ReplicatedStorage.Client.Modules.SharedTypes);

local ClientEffect: types.ClientEffectFactory = {} :: types.ClientEffectFactory;

-- Returns a ServerItem based on the ID.
function ClientEffect.get(effectID: string): types.ClientEffectClass

  local instance = script.Parent.Effects:FindFirstChild(`{effectID}ClientEffect`);
  if instance and instance:IsA("ModuleScript") then

    local effect = require(instance) :: any;
    return effect;

  end

  error(`Couldn't find item from ID {effectID}.`);

end;

-- Returns a random ServerEffect
function ClientEffect.random(): types.ClientEffectClass

  local children = script.Parent.Effects:GetChildren();
  local selectedChild = children[math.random(1, #children)];
  local effect = require(selectedChild) :: any;
  return effect;

end;

return ClientEffect;