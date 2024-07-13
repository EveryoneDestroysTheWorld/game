--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local Stage = require(ServerStorage.Classes.Stage);
local ServerRound = require(ServerStorage.Classes.ServerRound);
local TurfWarGameMode = require(ServerStorage.Classes.GameModes.TurfWarGameMode);
local ServerContestant = require(ServerStorage.Classes.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerArchetype = require(ServerStorage.Classes.ServerArchetype);
type ServerArchetype = ServerArchetype.ServerArchetype;
local Profile = require(ServerStorage.Classes.Profile);

-- Download a random stage from the stage list.
local stage;
local shouldGetRandomStage = true;
if game.PrivateServerId ~= "" then

  stage = Stage.fromPrivateServerID(game.PrivateServerId)

elseif shouldGetRandomStage then

  -- This should only happen during test times.
  stage = Stage.random();

else

  ReplicatedStorage.Shared.Events.RoundStopped:FireAllClients()
  
  Players.PlayerAdded:Connect(function(player)
  
    ReplicatedStorage.Shared.Events.RoundStopped:FireClient(player);

  end);
  
  return;

end;

local stageModel = stage:download();
stageModel.Parent = workspace;

-- Initialize the round.
local round = ServerRound.new({
  ID = HttpService:GenerateGUID();
  stageID = stage.ID :: string;
  contestants = {};
  duration = 1500;
  status = "Waiting for players";
});

round:setGameMode(TurfWarGameMode.new(stageModel, round));

ReplicatedStorage.Shared.Functions.GetRound.OnServerInvoke = function()

  assert(round, "The server hasn't initialized the round yet.");

  -- Convert the ServerRound to a ClientRound.
  return round:getClientConstructorProperties();

end;

-- Get the match info.
local expectedPlayerIDs = {904459813};

local function startRound()

  -- TODO: Wrap this entire thing in a pcall and send a signal if the thing fails
  -- Create required bot contestants.
  local team1BotCount = 4;
  local team2BotCount = 4;
  for _, contestant in ipairs(round.contestants) do

    if contestant.teamID == 1 then

      team1BotCount -= 1;

    elseif contestant.teamID == 2 then

      team2BotCount -= 1;

    else 

      warn(`Contestant {contestant.name} ({contestant.ID}) doesn't have a team.`)

    end;

  end;

  for i = 1, team1BotCount + team2BotCount do

    -- Create the NPC's character.
    local character: Model = ServerStorage:FindFirstChild("NPCRigs"):FindFirstChild("Rig"):Clone();
    character.Name = "NPC" .. i;

    -- Add the NPC to the contestant list.
    local botContestant = ServerContestant.new({
      ID = i * 0.01;
      character = character;
      name = `NPC {i * 0.01}`;
      isBot = true;
      isDisqualified = false;
      teamID = if i > team1BotCount then 2 else 1;
    });

    round:addContestant(botContestant);

  end;

  -- Let the players choose an archetype that they own.
  local function getContestantFromPlayer(player: Player): ServerContestant?

    for _, contestant in ipairs(round.contestants) do

      if contestant.player == player then

        return contestant;

      end;

    end;

    return nil;

  end;

  ReplicatedStorage.Shared.Functions.GetArchetypeIDs.OnServerInvoke = function(player): {number}

    local contestant = getContestantFromPlayer(player);
    assert(contestant, `{player.Name} ({player.UserId}) isn't a contestant in this round, so it is unnecessary to get the archetype list.`);
    assert(contestant.profile, "Couldn't find the player's profile.");

    -- Verify that the player has the default archetypes.
    local archetypeIDs = contestant.profile:getArchetypeIDs();
    local newArchetypeIDs: {number}? = nil;
    for i = 1, 1 do

      if not table.find(archetypeIDs, i) then

        newArchetypeIDs = newArchetypeIDs or table.clone(archetypeIDs);
        table.insert(newArchetypeIDs :: {number}, i);

      end;

    end;

    -- Return the archetype IDs.
    if newArchetypeIDs then

      contestant.profile:updateArchetypeIDs(newArchetypeIDs);
      return newArchetypeIDs;

    end;

    return archetypeIDs;

  end;

  local chosenArchetypeIDs = {};
  ReplicatedStorage.Shared.Functions.ChooseArchetype.OnServerInvoke = function(player, archetypeID)

    -- Verify that the player is a contestant.
    local contestant = getContestantFromPlayer(player);
    local playerIdentifier = `{player.Name} ({player.UserId})`;
    assert(contestant, `{playerIdentifier} isn't a contestant in this round, so it is unnecessary for them to choose an archetype.`);
    assert(contestant.profile, `Couldn't find the {playerIdentifier}'s profile.`);

    -- Verify that the archetype ID is valid.
    assert(table.find(contestant.profile:getArchetypeIDs(), archetypeID), `{playerIdentifier} doesn't own archetype {archetypeID}, so it can't be used in this round.`);

    -- Update the archetype.
    chosenArchetypeIDs[contestant] = archetypeID;

    -- Let every team member know.
    for _, possibleTeammate in ipairs(round.contestants) do

      if possibleTeammate.teamID == contestant.teamID and possibleTeammate.player then

        ReplicatedStorage.Shared.Events.TeamMemberArchetypePrivatelyChosen:FireClient(possibleTeammate.player, contestant.ID, archetypeID);

      end;

    end;

  end;

  round:setStatus("Contestant selection");
  local selectionTimeLimitSeconds = 15;
  ReplicatedStorage.Shared.Events.ArchetypeSelectionsEnabled:FireAllClients(selectionTimeLimitSeconds);

  task.delay(selectionTimeLimitSeconds, function()

    -- Block selections.
    ReplicatedStorage.Shared.Functions.GetArchetypeIDs.OnServerInvoke = nil;
    ReplicatedStorage.Shared.Functions.ChooseArchetype.OnServerInvoke = nil;
    ReplicatedStorage.Shared.Events.ArchetypeSelectionsFinalized:FireAllClients();
  
    -- Verify that each contestant has an archetype.
    for _, contestant in ipairs(round.contestants) do

      local chosenArchetypeID = chosenArchetypeIDs[contestant];
      if not chosenArchetypeID then

        local ownedArchetypeIDs = {};
        if contestant.isBot then

          for _, archetype in ipairs(ServerArchetype.getAll()) do

            table.insert(ownedArchetypeIDs, archetype.ID);

          end;

        elseif contestant.profile then

          ownedArchetypeIDs = contestant.profile:getArchetypeIDs();

        end;

        if contestant.teamID then

          -- Choose an archetype of a class that the team doesn't have.
          local neededTypes = {"Destroyer", "Defender", "Fighter", "Supporter"};
          for _, possibleTeammate in ipairs(round.contestants) do

            if #neededTypes == 0 then

              break;

            end;

            if possibleTeammate.archetypeID and possibleTeammate.teamID == contestant.teamID then

              local archetype = ServerArchetype.get(possibleTeammate.archetypeID);
              local typeIndex = table.find(neededTypes, archetype.type);
              if typeIndex then

                table.remove(neededTypes, typeIndex);

              end;

            end;

          end;

          if #neededTypes > 0 then

            local eligbleArchetypeIDs = {};
            for _, archetypeID in ipairs(ownedArchetypeIDs) do

              local archetype = ServerArchetype.get(archetypeID);
              if table.find(neededTypes, archetype.type) then

                table.insert(eligbleArchetypeIDs, archetypeID);

              end;

            end;

            ownedArchetypeIDs = eligbleArchetypeIDs;

          end;

        end;

        -- Choose a random archetype for those who didn't choose.
        local selectedArchetypeIndex = math.random(1, #ownedArchetypeIDs);
        chosenArchetypeID = ownedArchetypeIDs[selectedArchetypeIndex];

      end

      contestant:updateArchetypeID(chosenArchetypeID);

    end;

  end);

end;

local function checkPlayerList(player: Player)

  for index, playerID in ipairs(expectedPlayerIDs) do

    if playerID == player.UserId then

      -- Verify that the player has at least one archetype.
      local profile = Profile.fromID(playerID);
      round:addContestant(ServerContestant.new({
        ID = player.UserId;
        player = player;
        character = player.Character;
        name = player.Name;
        profile = profile;
        isBot = false;
        isDisqualified = false;
        teamID = 1;
      }));

      break;

    end;

  end;

  -- Verify that all expected players joined the server.
  for _, playerID in ipairs(expectedPlayerIDs) do

    if not Players:GetPlayerByUserId(playerID) then

      return;

    end;

  end;

  -- We have all expected players, so start the round.
  startRound();

end;

Players.PlayerAdded:Connect(function(player)

  checkPlayerList(player);

end);

for _, player in ipairs(Players:GetPlayers()) do

  checkPlayerList(player);

end;