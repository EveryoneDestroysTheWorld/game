--!strict

local types = require(script.Parent.types);

local ServerEffect: types.ServerEffectFactory = {} :: types.ServerEffectFactory;

-- Returns a ServerItem based on the ID.
function ServerEffect.get(effectID: string): types.ServerEffectClass

  local instance = script.Parent.Effects:FindFirstChild(`{effectID}ServerEffect`);
  if instance and instance:IsA("ModuleScript") then

    local effect = require(instance) :: any;
    return effect;

  end

  error(`Couldn't find effect from ID {effectID}.`);

end;

-- Returns a random ServerEffect
function ServerEffect.random(): types.ServerEffectClass

  local children = script.Parent.Effects:GetChildren();
  local selectedChild = children[math.random(1, #children)];
  local effect = require(selectedChild) :: any;
  return effect;

end;

return ServerEffect;