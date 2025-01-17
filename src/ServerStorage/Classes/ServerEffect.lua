local ServerStorage = game:GetService("ServerStorage");

local Cause = require(ServerStorage.Types["Cause.types"]);
type Cause = Cause.Cause;

export type ServerEffect = {
  name: string;
  id: string;
  description: string?;
  expirationTimeMilliseconds: number?;
  activate: ((effect: ServerEffect, ...any) -> ())?;
  deactivate: ((effect: ServerEffect, ...any) -> ())?;
  updateContestantHealth: ((effect: ServerEffect, newHealth: number, oldHealth: number, cause: Cause?) -> number)?;
  updateContestantStamina: ((effect: ServerEffect, newHealth: number, oldHealth: number, cause: Cause?) -> number)?;
}

local ServerEffect = {};

-- Returns a ServerItem based on the ID.
function ServerEffect.get(itemID: string): ServerEffect

  local instance = script.Parent.Effects:FindFirstChild(itemID);
  if instance:IsA("ModuleScript") then

    local item = require(instance) :: any;
    if item.id == itemID then

      return setmetatable(item, {});

    end;

  end

  error(`Couldn't find item from ID {itemID}.`);

end;

-- Returns a random ServerEffect
function ServerEffect.random(): ServerEffect

  local children = script.Parent.ServerEffect:GetChildren();
  local selectedChild = children[math.random(1, #children)];
  local item = require(selectedChild) :: any;
  return setmetatable(item, {});

end;

return ServerEffect;