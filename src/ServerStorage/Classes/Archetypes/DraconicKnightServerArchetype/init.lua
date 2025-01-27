--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local InsertService = game:GetService("InsertService");
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
  __index = {};
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

  local archetype = (setmetatable(overwrittenProperties, DraconicKnightServerArchetype) :: unknown) :: types.DraconicKnightServerArchetype
  
  local function setUpPropsDragonKnight(model)
    
    wingsProp:FindFirstChild("WingProp").Parent = model
    wingsProp:Destroy();
    local newWingProp = model.WingProp;
    (newWingProp:FindFirstChild("Root") :: any).RigidConstraint.Attachment1 = model:FindFirstChild("BodyBackAttachment", true)

    -- Creates effects and folder for draconicknight if it doesnt already exist
    if not ReplicatedStorage.Client.InGameDisplayObjects:FindFirstChild("DraconicKnight") then

      local classFolder = Instance.new("Folder", ReplicatedStorage.Client.InGameDisplayObjects)
      classFolder.Name = "DraconicKnight"

      local diveBombIndicator = InsertService:LoadAsset(124109899420589)
      diveBombIndicator.AoeDisplay.Name = "DiveBombIndicator"
      diveBombIndicator.DiveBombIndicator.PrimaryPart.Position = Vector3.new(0,9999,0)
      diveBombIndicator.DiveBombIndicator.Parent = classFolder
      diveBombIndicator:Destroy()

      local fireBeamProp = InsertService:LoadAsset(132308940043685)
      fireBeamProp.FireBeam.Name = "FireBeamProp"
      fireBeamProp.FireBeamProp.Parent = classFolder
      fireBeamProp:Destroy()

      local fireDebuffProp = InsertService:LoadAsset(131535660581587)
      fireDebuffProp.FirePlayer.Name = "FireDebuffProp"
      fireDebuffProp.FireDebuffProp.Parent = classFolder
      fireDebuffProp:Destroy()
      

      local fireBeamGUI = InsertService:LoadAsset(83599259067516)
      fireBeamGUI.Charge.Name = "ChargeMeter"
      fireBeamGUI.ChargeMeter.Parent = classFolder
      fireBeamGUI:Destroy()

      local chargedAttackEffect = InsertService:LoadAsset(117856122514203)
      chargedAttackEffect.ChargedAttack.Name = "ChargedAttackEffect"
      chargedAttackEffect.ChargedAttackEffect.Parent = classFolder
      chargedAttackEffect:Destroy()


      local tarBomb = InsertService:LoadAsset(134163908471327)
      tarBomb.TarBomb.Parent = classFolder
      chargedAttackEffect:Destroy()
      local animData = InsertService:LoadAsset(113409826866728)
      animData.DKAnimData.Parent = classFolder.Parent
      animData:Destroy();
      
    end
    archetype.wingProp = newWingProp;

  end
    
  setUpPropsDragonKnight(properties.contestant["character"]);

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
  
  if wingProp then

    wingProp:Destroy()
    
  end

  if self.ragdollClone then

    self.ragdollClone:Destroy();

  end;

  self.contestant:removeEffect(self.roughArmorEffect);

end;

return DraconicKnightServerArchetype;