--!strict
-- Written by Christian Toney (Sudobeast)

local Action = require(script.Parent.Parent.Action);

local ExplosiveLimbAttack = setmetatable({
  __index = {};
}, Action);

local initialProperties = {
  ID = 1;
  name = "Detach Limb";
};

export type ExplosiveLimbAttack = typeof(setmetatable(Action.new(initialProperties), {__index = ExplosiveLimbAttack.__index}));

function ExplosiveLimbAttack.new(): ExplosiveLimbAttack

  return setmetatable(Action.new(initialProperties), ExplosiveLimbAttack.__index);

end

function ExplosiveLimbAttack.__index:initialize(): ()
  
end;

function ExplosiveLimbAttack.__index:activate(): ()

end;

function ExplosiveLimbAttack.__index:breakdown(): ()

end;

return ExplosiveLimbAttack;