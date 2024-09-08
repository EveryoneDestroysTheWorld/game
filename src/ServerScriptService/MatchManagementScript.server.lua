--!strict
-- Profile.lua
-- Written by Christian "Sudobeast" Toney
-- Edits by Hati :))))
-- This script controls the round and lobby management stuff.

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local Stage = require(ServerStorage.Classes.Stage);
local ServerRound = require(ServerStorage.Classes.ServerRound);
local ServerContestant = require(ServerStorage.Classes.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerArchetype = require(ServerStorage.Classes.ServerArchetype);
type ServerArchetype = ServerArchetype.ServerArchetype;
local Profile = require(ServerStorage.Classes.Profile);
local RunService = game:GetService("RunService");

-- Initialize the round.
local round;
local didSuccessfullyInitializeRound, message = pcall(function()

  local shouldCreateRound = true;
  if shouldCreateRound then

    round = ServerRound.new({
      ID = HttpService:GenerateGUID();
      stageID = Stage.random().ID :: string;
      gameModeID = 1;
      contestantIDs = {};
      duration = 180;
      status = "Waiting for players" :: "Waiting for players";
    });

  elseif game.PrivateServerId ~= "" then

    round = ServerRound.fromPrivateServerID(game.PrivateServerId);
    assert(round.stageID, "Round didn't have a stage ID.");

  end;
  
  round.stage:download().Parent = workspace;

end);

if not didSuccessfullyInitializeRound then

  ReplicatedStorage.Shared.Events.RoundStopped:FireAllClients()
  
  Players.PlayerAdded:Connect(function(player)
  
    ReplicatedStorage.Shared.Events.RoundStopped:FireClient(player);

  end);
  
  error(message);

end;

ReplicatedStorage.Shared.Functions.GetRound.OnServerInvoke = function()

  assert(round, "The server hasn't initialized the round yet.");

  -- Convert the ServerRound to a ClientRound.
  return round:getClientConstructorProperties();

end;

-- Get the match info.
local expectedPlayerIDs = {};

local function startRound()

  local isSuccess, message = pcall(function()

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

    local delayTask = nil;
    local chosenArchetypeIDs = {};
    local function previewMatchup()

      local isSuccess, message = pcall(function()

        if coroutine.status(delayTask) ~= "running" then

          task.cancel(delayTask);

        end;

        -- Block selections.
        ReplicatedStorage.Shared.Functions.GetPreRoundTimeLimit.OnServerInvoke = nil;
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

                if #eligbleArchetypeIDs > 0 then
                  
                  ownedArchetypeIDs = eligbleArchetypeIDs;

                end;

              end;

            end;

            -- Choose a random archetype for those who didn't choose.
            print(ownedArchetypeIDs);
            local selectedArchetypeIndex = math.random(1, #ownedArchetypeIDs);
            chosenArchetypeID = ownedArchetypeIDs[selectedArchetypeIndex];

          end

          contestant:updateArchetypeID(chosenArchetypeID);

        end;

        round:setStatus("Matchup preview");

        task.wait(7);
        
        round:setStatus("Stage preview");

        for _, contestant in ipairs(round.contestants) do

          if contestant.player then

            contestant.player:LoadCharacter();
            contestant:updateCharacter(contestant.player.Character);

          else

            local character = ServerStorage.NPCRigs.Rig:Clone();
            character.Name = contestant.name;
            character.Parent = workspace;
            for _, part in ipairs(character:GetDescendants()) do

              if part:IsA("BasePart") then

                part:SetNetworkOwner(nil);

              end;

            end;
            contestant:updateCharacter(character);

          end;

        end;

        task.wait(3);
        round:setStatus("Pre-round countdown");
        task.wait(3);
        round:setStatus("Active");
        round:start(round.stage.model :: Model);

      end);

      if not isSuccess then

        round:stop(true);
        error(message);

      end;

    end;

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

      local shouldContinue = true;
      for _, possibleTeammate in ipairs(round.contestants) do

        if possibleTeammate.player then

          -- Privately let every player teammate know about the change.
          if possibleTeammate.teamID == contestant.teamID then

            ReplicatedStorage.Shared.Events.ArchetypePrivatelyChosen:FireClient(possibleTeammate.player, contestant.ID, archetypeID);

          end;

          -- Check if every player made their selection
          if not chosenArchetypeIDs[possibleTeammate] then

            shouldContinue = false;

          end;

        end;

      end;

      if shouldContinue then

        print('chosen')
        previewMatchup();

      end;

    end;

    round:setStatus("Contestant selection");
    local selectionTimeLimitSeconds = 25; 
    local currentTime = os.time();
    ReplicatedStorage.Shared.Events.ArchetypeSelectionsEnabled:FireAllClients(selectionTimeLimitSeconds - 1);
    ReplicatedStorage.Shared.Functions.GetPreRoundTimeLimit.OnServerInvoke = function()

      return os.time() - currentTime + selectionTimeLimitSeconds - 1;

    end;

    delayTask = task.delay(selectionTimeLimitSeconds, previewMatchup);

  end);

  if not isSuccess then

    round:stop(true);
    error(message);

  end;

end;

local function checkPlayerList(player: Player)

  for index, playerID in ipairs(expectedPlayerIDs) do

    if playerID == player.UserId then

      -- Verify that the player has at least one archetype.
      local profile = Profile.fromID(playerID, true);    --- edit
      round:addContestant(ServerContestant.new({
        ID = player.UserId;
        player = player;
        character = player.Character;
        name = player.Name;
        profile = profile;
        isBot = false;
        isDisqualified = false;
        teamID = 1; -- TODO: Fix this
      }));

    else

      warn("PlayerID doesn't exist, something went wrong");
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

local shouldUseStudioPlayers = true;
if shouldUseStudioPlayers and RunService:IsStudio() then

  Players.PlayerAdded:Connect(function(player)

    table.insert(expectedPlayerIDs, player.UserId)
    checkPlayerList(player);
    
  end);

  for _, player in ipairs(Players:GetPlayers()) do

    table.insert(expectedPlayerIDs, player.UserId)
    checkPlayerList(player);

  end;

end;