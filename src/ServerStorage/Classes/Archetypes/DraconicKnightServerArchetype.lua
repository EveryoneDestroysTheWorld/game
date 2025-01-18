--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local InsertService = game:GetService("InsertService");
local ServerStorage = game:GetService("ServerStorage");
local ServerArchetype = require(script.Parent.Parent.ServerArchetype);
local DraconicKnightClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.DraconicKnightClientArchetype);
local downContestant = require(ServerStorage.Modules.downContestant);
local createRagdollClone = require(ServerStorage.Modules.createRagdollClone);
local types = require(ServerStorage.Classes.types)

local DraconicKnightServerArchetype = {
  id = DraconicKnightClientArchetype.id;
  name = DraconicKnightClientArchetype.name;
  description = DraconicKnightClientArchetype.description;
  actionIDs = DraconicKnightClientArchetype.actionIDs;
  type = DraconicKnightClientArchetype.type;
};

function DraconicKnightServerArchetype.new(): types.ServerArchetype

  local contestant: types.ServerContestant = nil;
  local round: types.ServerRound = nil;
  local wingProp: Model?;
  local events: {RBXScriptConnection} = {};
  local ragdollClone;

  local function breakdown(self: types.ServerArchetype)

    for _, event in events do

      event:Disconnect();

    end;
    
    if wingProp then

      wingProp:Destroy()
      
    end

    if ragdollClone then

      ragdollClone:Destroy();

    end;

  end;

  local function runAutoPilot(self: types.ServerArchetype, actions: {types.ServerAction})

    -- Make sure the contestant has a character.
    local character = contestant.character
    assert(character, "Character not found");

    repeat

      

    until task.wait() and round.timeEnded;

  end;

  local function initialize(self: types.ServerArchetype, newContestant: types.ServerContestant, newRound: types.ServerRound)

    contestant = newContestant;
    round = newRound;
    contestant.character.Humanoid.WalkSpeed = 18
    local function setUpPropsDragonKnight(model)
      local wingsProp = InsertService:LoadAsset(76933185156855)
      
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
        animData:Destroy()
        
        
      end
      wingProp = newWingProp;

    end
      
    setUpPropsDragonKnight(contestant["character"]);

    if contestant.player then

      ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(contestant.player, self.id);

    end;

    local isDowned = false;
    table.insert(events, contestant.onHealthUpdated:Connect(function()
    
      if isDowned and contestant.currentHealth > 0 then
        
        isDowned = false;
        if ragdollClone then

          ragdollClone:Destroy();

        end;

      elseif not isDowned and contestant.currentHealth <= 0 then

        isDowned = true;

        if contestant.character then
          
          ragdollClone = createRagdollClone(contestant.character);

        end;

        downContestant(contestant);

      end;

    end));

  end;

  return ServerArchetype.new({
    id = DraconicKnightServerArchetype.id;
    name = DraconicKnightServerArchetype.name;
    description = DraconicKnightServerArchetype.description;
    actionIDs = DraconicKnightServerArchetype.actionIDs;
    type = DraconicKnightServerArchetype.type;
    breakdown = breakdown;
    runAutoPilot = runAutoPilot;
    initialize = initialize;
  });

end;

return DraconicKnightServerArchetype;