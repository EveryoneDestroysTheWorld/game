--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local DraconicKnightClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.DraconicKnightClientArchetype);
local ServerEffect = require(ServerStorage.Classes.ServerEffect);
local types = require(ServerStorage.Modules.types);

local initializeArchetypeActions = require(ServerStorage.Modules.initializeArchetypeActions);

local DraconicKnightServerArchetype = {
  id = DraconicKnightClientArchetype.id;
  name = DraconicKnightClientArchetype.name;
  description = DraconicKnightClientArchetype.description;
  actionIDs = DraconicKnightClientArchetype.actionIDs;
  type = DraconicKnightClientArchetype.type;
  __index = {} :: types.DraconicKnightServerArchetype;
};

function DraconicKnightServerArchetype.new(properties: types.DraconicKnightServerArchetypeConstructorProperties): types.DraconicKnightServerArchetype

  local archetype = (setmetatable({}, DraconicKnightServerArchetype) :: any) :: types.DraconicKnightServerArchetype;
  archetype.id = DraconicKnightServerArchetype.id;
  archetype.name = DraconicKnightServerArchetype.name;
  archetype.description = DraconicKnightServerArchetype.description;
  archetype.actionIDs = DraconicKnightServerArchetype.actionIDs;
  archetype.type = DraconicKnightServerArchetype.type;
  archetype.contestant = properties.contestant;
  archetype.roughArmorEffect = ServerEffect.get("RoughArmor").new({
    contestant = properties.contestant;
  });
  archetype.events = {};

  if properties.contestant.player then

    ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(properties.contestant.player, archetype.id);

  end;

  local character = properties.contestant.character;
  if character then

    local humanoid = character:FindFirstChild("Humanoid");
    if humanoid and humanoid:IsA("Humanoid") then

      humanoid.WalkSpeed = 18;

    end;

  end;
  
  if character then
    
    local newWingProp = ReplicatedStorage.Shared.InGameDisplayObjects.WingProp:Clone();
    assert(newWingProp and newWingProp:IsA("Model"));
    newWingProp.Parent = character;

    (newWingProp:FindFirstChild("Root") :: any).RigidConstraint.Attachment1 = character:FindFirstChild("BodyBackAttachment", true)
    archetype.wingProp = newWingProp;

  end

  properties.contestant:addEffect(archetype.roughArmorEffect);

  archetype.actions = initializeArchetypeActions(archetype.actionIDs, archetype.contestant);

  return archetype;

end;

function DraconicKnightServerArchetype.__index:breakdown()

  for _, event in self.events do

    event:Disconnect();

  end;
  
  if self.wingProp then

    self.wingProp:Destroy()
    
  end

  if self.ragdollClone then

    self.ragdollClone:Destroy();

  end;

  for _, action in self.actions do

    task.spawn(function()
    
      action:breakdown();

    end);

  end;

  self.contestant:removeEffect(self.roughArmorEffect);

end;

return DraconicKnightServerArchetype;