--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local DraconicKnightClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.DraconicKnightClientArchetype);
local ServerEffect = require(ServerStorage.Classes.ServerEffect);
local types = require(ServerStorage.Classes.types);

local downContestant = require(ServerStorage.Modules.downContestant);
local createRagdollClone = require(ServerStorage.Modules.createRagdollClone);

local DraconicKnightServerArchetype = {
  id = DraconicKnightClientArchetype.id;
  name = DraconicKnightClientArchetype.name;
  description = DraconicKnightClientArchetype.description;
  actionIDs = DraconicKnightClientArchetype.actionIDs;
  type = DraconicKnightClientArchetype.type;
  __index = {} :: types.DraconicKnightServerArchetype;
};

function DraconicKnightServerArchetype.new(properties: types.DraconicKnightServerArchetypeConstructorProperties): types.DraconicKnightServerArchetype

  local overwrittenProperties = {
    id = DraconicKnightServerArchetype.id;
    name = DraconicKnightServerArchetype.name;
    description = DraconicKnightServerArchetype.description;
    actionIDs = DraconicKnightServerArchetype.actionIDs;
    type = DraconicKnightServerArchetype.type;
    contestant = properties.contestant;
    roughArmorEffect = ServerEffect.get("RoughArmor").new({
      contestant = properties.contestant;
    });
    events = {};
  };

  local archetype = (setmetatable(overwrittenProperties, DraconicKnightServerArchetype) :: any) :: types.DraconicKnightServerArchetype;

  if properties.contestant.player then

    ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(properties.contestant.player, overwrittenProperties.id);

  end;

  local character = properties.contestant.character;
  if character then

    local humanoid = character:FindFirstChild("Humanoid");
    if humanoid and humanoid:IsA("Humanoid") then

      humanoid.WalkSpeed = 18;

    end;

  end;
  
  if character then
    
    local newWingProp = script.WingProp:Clone();
    assert(newWingProp and newWingProp:IsA("Model"));
    newWingProp.Parent = character;

    (newWingProp:FindFirstChild("Root") :: any).RigidConstraint.Attachment1 = character:FindFirstChild("BodyBackAttachment", true)

    -- Creates effects and folder for draconicknight if it doesnt already exist
    if not ReplicatedStorage.Client.InGameDisplayObjects:FindFirstChild("DraconicKnight") then

      local classFolder = Instance.new("Folder", ReplicatedStorage.Client.InGameDisplayObjects)
      classFolder.Name = "DraconicKnight"

      local diveBombIndicator = script.DiveBombIndicator:Clone();
      diveBombIndicator.PrimaryPart.Position = Vector3.new(0,9999,0)
      diveBombIndicator.Parent = classFolder

      local fireBeamProp = script.FireBeam:Clone();
      fireBeamProp.Parent = classFolder

      local fireDebuffProp = script.FireDebuffProp:Clone();
      fireDebuffProp.Parent = classFolder
      
      local chargeMeterGUI = script.ChargeMeter:Clone();
      chargeMeterGUI.Parent = classFolder

      local chargedAttackEffect = script.ChargedAttackEffect:Clone();
      chargedAttackEffect.Parent = classFolder

      local tarBomb = script.TarBomb:Clone();
      tarBomb.Parent = classFolder

      local animData = script.AnimData:Clone();
      animData.Parent = classFolder.Parent
      
    end
    archetype.wingProp = newWingProp;

  end

  properties.contestant:addEffect(archetype.roughArmorEffect);

  local isDowned = false;
  table.insert(archetype.events, properties.contestant.onHealthUpdated:Connect(function()
  
    if isDowned and properties.contestant.currentHealth > 0 then
      
      isDowned = false;
      if archetype.ragdollClone then

        archetype.ragdollClone:Destroy();

      end;

      properties.contestant:addEffect(archetype.roughArmorEffect);

    elseif not isDowned and properties.contestant.currentHealth <= 0 then

      isDowned = true;

      if properties.contestant.character then
        
        archetype.ragdollClone = createRagdollClone(properties.contestant.character);

      end;

      properties.contestant:removeEffect(archetype.roughArmorEffect)

      downContestant(properties.contestant);

    end;

  end));

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

  self.contestant:removeEffect(self.roughArmorEffect);

end;

return DraconicKnightServerArchetype;