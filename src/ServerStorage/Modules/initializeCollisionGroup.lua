--!strict

local PhysicsService = game:GetService("PhysicsService");

local function initializeCollisionGroup(collisionGroupName: string, model: Model)

  PhysicsService:RegisterCollisionGroup(collisionGroupName);

  for _, part in model:GetChildren() do

    if part:IsA("BasePart") then

      part.CollisionGroup = collisionGroupName;

    end;

  end;

end;

return initializeCollisionGroup;