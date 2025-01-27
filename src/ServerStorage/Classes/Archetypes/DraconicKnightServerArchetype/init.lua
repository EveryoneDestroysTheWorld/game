--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local DraconicKnightClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.DraconicKnightClientArchetype);
local ServerEffect = require(ServerStorage.Classes.ServerEffect);

local downContestant = require(ServerStorage.Modules.downContestant);
local createRagdollClone = require(ServerStorage.Modules.createRagdollClone);

local types = require(ServerStorage.Classes.types)

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
    
    local wingsProp = script.WingsProp:Clone();
    wingsProp:FindFirstChild("WingProp").Parent = character;
    wingsProp:Destroy();

    local newWingProp = character:FindFirstChild("WingProp");
    assert(newWingProp and newWingProp:IsA("Model"));

    (newWingProp:FindFirstChild("Root") :: any).RigidConstraint.Attachment1 = character:FindFirstChild("BodyBackAttachment", true)

    -- Creates effects and folder for draconicknight if it doesnt already exist
    if not ReplicatedStorage.Client.InGameDisplayObjects:FindFirstChild("DraconicKnight") then

      local classFolder = Instance.new("Folder", ReplicatedStorage.Client.InGameDisplayObjects)
      classFolder.Name = "DraconicKnight"

      local diveBombIndicator = script.DiveBombIndicator:Clone();
      diveBombIndicator.AoeDisplay.Name = "DiveBombIndicator"
      diveBombIndicator.DiveBombIndicator.PrimaryPart.Position = Vector3.new(0,9999,0)
      diveBombIndicator.DiveBombIndicator.Parent = classFolder
      diveBombIndicator:Destroy()

      local fireBeamProp = script.FireBeam:Clone();
      fireBeamProp.FireBeam.Name = "FireBeamProp"
      fireBeamProp.FireBeamProp.Parent = classFolder
      fireBeamProp:Destroy()

      local fireDebuffProp = script.FireDebuffProp:Clone();
      fireDebuffProp.FirePlayer.Name = "FireDebuffProp"
      fireDebuffProp.FireDebuffProp.Parent = classFolder
      fireDebuffProp:Destroy()
      
      local fireBeamGUI = script.FireBeamGUI:Clone();
      fireBeamGUI.Charge.Name = "ChargeMeter"
      fireBeamGUI.ChargeMeter.Parent = classFolder
      fireBeamGUI:Destroy()

      local chargedAttackEffect = script.ChargedAttackEffect:Clone();
      chargedAttackEffect.ChargedAttack.Name = "ChargedAttackEffect"
      chargedAttackEffect.ChargedAttackEffect.Parent = classFolder
      chargedAttackEffect:Destroy()


      local tarBomb = script.TarBomb:Clone();
      tarBomb.TarBomb.Parent = classFolder
      chargedAttackEffect:Destroy()

      local animData = script.AnimData:Clone();
      animData.DKAnimData.Parent = classFolder.Parent
      animData:Destroy();
      
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