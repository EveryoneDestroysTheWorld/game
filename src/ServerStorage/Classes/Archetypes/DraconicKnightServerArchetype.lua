--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local InsertService = game:GetService("InsertService");
local ServerArchetype = require(script.Parent.Parent.ServerArchetype);
local ServerContestant = require(script.Parent.Parent.ServerContestant);
local DraconicKnightClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.DraconicKnightClientArchetype);
local ServerRound = require(script.Parent.Parent.ServerRound);
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerRound = ServerRound.ServerRound;
type ServerContestant = ServerContestant.ServerContestant;
type ServerArchetype = ServerArchetype.ServerArchetype;
type ServerAction = ServerAction.ServerAction;

local DraconicKnightServerArchetype = {
  ID = DraconicKnightClientArchetype.ID;
  name = DraconicKnightClientArchetype.name;
  description = DraconicKnightClientArchetype.description;
  actionIDs = DraconicKnightClientArchetype.actionIDs;
  type = DraconicKnightClientArchetype.type;
};


function DraconicKnightServerArchetype.new(): ServerArchetype

  local contestant: ServerContestant = nil;
  local round: ServerRound = nil;
  local wingProp: Model?;

  local function breakdown(self: ServerArchetype)

    if wingProp then

      wingProp:Destroy()

    end;

  end;

  local function runAutoPilot(self: ServerArchetype, actions: {ServerAction})

    -- Make sure the contestant has a character.
    local character = contestant.character
    assert(character, "Character not found");

    repeat

      

    until task.wait() and round.timeEnded;

  end;

  local function initialize(self: ServerArchetype, newContestant: ServerContestant, newRound: ServerRound)

    contestant = newContestant;
    round = newRound;
    
    local function setUpPropsDragonKnight(model)
      local wingsProp = InsertService:LoadAsset(76933185156855)
      wingsProp:FindFirstChild("WingProp").Parent = model
      wingsProp:Destroy();
      local newWingProp = model.WingProp;
      (newWingProp:FindFirstChild("Root") :: any).RigidConstraint.Attachment1 = model:FindFirstChild("BodyBackAttachment", true)
        
      if not ReplicatedStorage.Client.InGameDisplayObjects:FindFirstChild("DiveBombIndicator") then

        local diveBombIndicator = InsertService:LoadAsset(124109899420589)
        diveBombIndicator.AoeDisplay.Name = "DiveBombIndicator"
        diveBombIndicator.DiveBombIndicator.Parent = ReplicatedStorage.Client.InGameDisplayObjects
        diveBombIndicator:Destroy()
        
      end

      wingProp = newWingProp;

    end
      
    setUpPropsDragonKnight(contestant["character"]);

    if contestant.player then

      ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(contestant.player, self.ID);

    end;

  end;

  return ServerArchetype.new({
    ID = DraconicKnightServerArchetype.ID;
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