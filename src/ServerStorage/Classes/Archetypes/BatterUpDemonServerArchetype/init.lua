--!strict

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local BatterUpDemonClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.BatterUpDemonClientArchetype);
local ServerAction = require(ServerStorage.Classes.ServerAction);

local downContestant = require(ServerStorage.Modules.downContestant);
local createRagdollClone = require(ServerStorage.Modules.createRagdollClone);
local initializeArchetypeActions = require(ServerStorage.Modules.initializeArchetypeActions);
local filterTable = require(ReplicatedStorage.Shared.Modules.filterTable);

local types = require(ServerStorage.Modules.types);

local BatterUpDemonServerArchetype = {
  id = BatterUpDemonClientArchetype.id;
  name = BatterUpDemonClientArchetype.name;
  description = BatterUpDemonClientArchetype.description;
  actionIDs = BatterUpDemonClientArchetype.actionIDs;
  type = BatterUpDemonClientArchetype.type;
  __index = {} :: types.BatterUpDemonServerArchetype;
};

function BatterUpDemonServerArchetype.new(properties: types.BatterUpDemonServerArchetypeConstructorProperties): types.BatterUpDemonServerArchetype

  local archetype = (setmetatable({}, BatterUpDemonServerArchetype) :: any) :: types.BatterUpDemonServerArchetype;
  archetype.id = BatterUpDemonClientArchetype.id;
  archetype.name = BatterUpDemonClientArchetype.name;
  archetype.description = BatterUpDemonClientArchetype.description;
  archetype.actionIDs = BatterUpDemonClientArchetype.actionIDs;
  archetype.type = BatterUpDemonClientArchetype.type :: types.ArchetypeType;
  archetype.events = {};
  archetype.contestant = properties.contestant;

  archetype.contestant.attributes.archetypeMode = "Pitcher";
  ServerStorage.Events.ArchetypeModeChanged:Fire(archetype.contestant.id);

  local function isActionIDAllowed(actionID: string): boolean

    local allowedActionIDs = if archetype.contestant.attributes.archetypeMode == "Pitcher" then {"HeresThePitch", "ChangeBallType"} else {"StrikeOutSwipe"};
    table.insert(allowedActionIDs, "ChangeModes");

    return not not table.find(allowedActionIDs, actionID);

  end;

  if properties.contestant.player then

    task.spawn(function()
      
      ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(archetype.contestant.player, archetype.id);
    
    end);

  end;

  table.insert(archetype.events, archetype.contestant.onHealthUpdated:Connect(function()
  
    if archetype.isContestantDowned and archetype.contestant.currentHealth > 0 then
      
      if archetype.ragdollClone then

        archetype.ragdollClone:Destroy();

      end;

    elseif not archetype.isContestantDowned and archetype.contestant.currentHealth <= 0 then

      archetype.isContestantDowned = true;

      if archetype.contestant.character then

        archetype.ragdollClone = createRagdollClone(archetype.contestant.character);

      end;

      downContestant(archetype.contestant);

    end;

  end));

  archetype.actions = initializeArchetypeActions(filterTable(archetype.actionIDs, isActionIDAllowed), archetype.contestant);
  table.insert(archetype.events, ServerStorage.Events.ArchetypeModeChanged.Event:Connect(function(contestantID: number)
  
    local character = archetype.contestant.character;
    if contestantID == archetype.contestant.id and archetype.contestant.attributes.archetypeMode == "Batter" then

      local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
      if humanoid and humanoid:IsA("Humanoid") then

        local bat = script.Bat:Clone();
        humanoid:AddAccessory(bat);

      end

    else

      local bat = if character then character:FindFirstChild("Bat") else nil;
      if bat then

        bat:Destroy();

      end;

    end;

    for _, actionID in archetype.actionIDs do

      task.spawn(function()

        local shouldCreateAction = true;
        for _, action in ipairs(archetype.actions) do

          if action.id == actionID then

            if not isActionIDAllowed(action.id) then

              action:breakdown();

              local index = table.find(archetype.actions, action);
              if index then

                table.remove(archetype.actions, index);

              end;

            end;

            shouldCreateAction = false;
            break;

          end;

        end;

        if shouldCreateAction then

          local action = ServerAction.get(actionID).new({
            contestant = archetype.contestant;
          })

          table.insert(archetype.actions, action);

        end;
        
      end);

    end;

  end));

  return archetype;

end;

function BatterUpDemonServerArchetype.__index:breakdown()

  for _, event in self.events do

    event:Disconnect();

  end;

  if self.ragdollClone then

    self.ragdollClone:Destroy();
    
  end;

  for _, action in self.actions do

    task.spawn(function()
    
      action:breakdown();

    end);

  end;

end;

return BatterUpDemonServerArchetype;