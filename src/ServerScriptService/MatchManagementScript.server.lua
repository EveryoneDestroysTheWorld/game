-- --!strict
-- Programmers: Christian Toney (Christian_Toney) and Hati (hati_bati) :))))
-- This script controls the round management stuff.

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local Stage = require(ServerStorage.Packages.Stage);
local ServerRound = require(ServerStorage.Classes.ServerRound);
local ServerContestant = require(ServerStorage.Classes.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerArchetype = require(ServerStorage.Classes.ServerArchetype);
type ServerArchetype = ServerArchetype.ServerArchetype;
local Profile = require(ServerStorage.Packages.Profile);

-- Initialize the round.
local round;
local didSuccessfullyInitializeRound, message = pcall(function()

  if script:HasTag("DebugAllPlayersAreContestants") then

    round = ServerRound.new({
      id = HttpService:GenerateGUID();
      stageID = Stage.random().id :: string;
      gameModeID = "TurfWar";
      contestantIDs = {};
      duration = script:GetAttribute("DebugRoundDuration");
      status = "Waiting for players" :: "Waiting for players";
    });

  elseif game.PrivateServerId ~= "" then

    round = ServerRound.fromPrivateServerID(game.PrivateServerId);
    assert(round.stageID, "Round didn't have a stage ID.");

  end;
  
  round.stage:download().Parent = workspace;

  ReplicatedStorage.Shared.Functions.GetRound.OnServerInvoke = function()

    assert(round, "The server hasn't initialized the round yet.");
  
    -- Convert the ServerRound to a ClientRound.
    return round:getClientConstructorProperties();
  
  end;
  
  local function getContestantFromPlayer(player: Player): ServerContestant?
  
    for _, contestant in ipairs(round.contestants) do
  
      if contestant.player == player then
  
        return contestant;
  
      end;
  
    end;
  
    return nil;
  
  end;
  
  ReplicatedStorage.Shared.Functions.GetArchetypeIDs.OnServerInvoke = function(player: Player): {string}
  
    local contestant = getContestantFromPlayer(player);
    assert(contestant, `{player.Name} ({player.UserId}) isn't a contestant in this round, so it is unnecessary to get the archetype list.`);
    assert(contestant.profile, "Couldn't find the player's profile.");
  
    -- Verify that the player has the default archetypes.
    local archetypeIDs = contestant.profile:getArchetypeIDs();
    local _newArchetypeIDs: {string}? = nil;
    for _, archetypeID in {"ExplosiveMimic", "BatterUpDemon", "DraconicKnight", "UndeadConciousness"} do
  
      if not table.find(archetypeIDs, archetypeID) then
  
        local newArchetypeIDs = _newArchetypeIDs or table.clone(archetypeIDs);
        table.insert(newArchetypeIDs, archetypeID);
        _newArchetypeIDs = newArchetypeIDs;
  
      end;
  
    end;
    
    -- Return the archetype IDs.
    if _newArchetypeIDs then
  
      contestant.profile:updateArchetypeIDs(_newArchetypeIDs);
  
    end;
  
    return _newArchetypeIDs or archetypeIDs;
  
  end;
  
  ReplicatedStorage.Shared.Functions.ChooseArchetype.OnServerInvoke = function(player: Player, archetypeID: unknown): ()
  
    -- Verify that the player is a contestant.
    local contestant = getContestantFromPlayer(player);
    local playerIdentifier = `{player.Name} ({player.UserId})`;
    assert(contestant, `{playerIdentifier} isn't a contestant in this round, so it is unnecessary for them to choose an archetype.`);
    assert(contestant.profile, `Couldn't find the {playerIdentifier}'s profile.`);
  
    -- Verify that the contestant has that archetype.
    assert(table.find(contestant.profile:getArchetypeIDs(), archetypeID), `{playerIdentifier} doesn't own archetype {archetypeID}, so it can't be used in this round.`);
  
    -- Update the archetype.
    contestant:updateArchetypeID(archetypeID);
  
  end;
  
  -- Get the match info.
  local expectedPlayerIDs = {};
  
  local function startRound()
  
    -- Create required bot contestants.
    local team1BotCount = 4;
    local team2BotCount = 4;
    for _, contestant in ipairs(round.contestants) do
  
      if contestant.teamID == 1 then
  
        team1BotCount -= 1;
  
      elseif contestant.teamID == 2 then
  
        team2BotCount -= 1;
  
      else 
  
        warn(`Contestant {contestant.name} ({contestant.id}) doesn't have a team.`)
  
      end;
  
    end;
  
    for i = 1, team1BotCount + team2BotCount do
  
      -- Create the NPC's character.
      local character: Model = ServerStorage:FindFirstChild("NPCRigs"):FindFirstChild("Rig"):Clone();
      character.Name = "NPC" .. i;
  
      -- Add the NPC to the contestant list.
      local botContestant = ServerContestant.new({
        id = i * 0.01;
        character = character;
        effects = {};
        name = `NPC {i * 0.01}`;
        inventory = {};
        isBot = true;
        isDisqualified = false;
        teamID = if i > team1BotCount then 2 else 1;
        baseHealth = 100;
        currentHealth = 100;
        baseStamina = 100;
        currentStamina = 100;
      });
  
      round:addContestant(botContestant);
  
    end;
  
    -- Show each contestant their rivals.
    round:setStatus("Matchup preview");
  
    task.wait(3);
    
    round:setStatus("Initializing character models");
  
    for _, contestant in ipairs(round.contestants) do
  
      if contestant.player then
  
        contestant.player:LoadCharacter();
        contestant:updateCharacter(contestant.player.Character);
  
      else
  
        local character = ServerStorage.NPCRigs.Rig:Clone();
        character.Name = contestant.name;
        character.Parent = workspace;
  
        local function resetNetworkOwnership(instance: Instance)
  
          if instance:IsA("BasePart") then
  
            while not instance:CanSetNetworkOwnership() do 
              
              task.wait();
  
            end;
            
            instance:SetNetworkOwner();
  
          end;
  
        end;
  
        character.DescendantAdded:Connect(resetNetworkOwnership);
  
        for _, part in ipairs(character:GetDescendants()) do
  
          if part:IsA("BasePart") then
  
            part:SetNetworkOwner();
  
          end;
  
        end;
  
        contestant:updateCharacter(character);
  
      end;
  
    end; 
  
    -- All clear!
    round:setStatus("Active");
    round:start();
  
  end;
  
  local function checkPlayerList(player: Player)
  
    for index, playerID in ipairs(expectedPlayerIDs) do
  
      if playerID == player.UserId then
  
        -- Verify that the player has at least one archetype.
        local profile = Profile.fromID(playerID, true);    --- edit
        round:addContestant(ServerContestant.new({
          id = player.UserId;
          player = player;
          character = player.Character;
          name = player.Name;
          effects = {};
          inventory = {};
          profile = profile;
          isBot = false;
          isDisqualified = false;
          teamID = 1; -- TODO: Fix this
          baseHealth = 100;
          currentHealth = 100;
          baseStamina = 100;
          currentStamina = 100;
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
  
  Players.PlayerAdded:Connect(function(player)
  
    table.insert(expectedPlayerIDs, player.UserId)
    checkPlayerList(player);
    
  end);
  
  for _, player in ipairs(Players:GetPlayers()) do
  
    table.insert(expectedPlayerIDs, player.UserId)
    checkPlayerList(player);
  
  end;

end);

if not didSuccessfullyInitializeRound then

  ReplicatedStorage.Shared.Events.RoundStopped:FireAllClients()
  
  Players.PlayerAdded:Connect(function(player)
  
    ReplicatedStorage.Shared.Events.RoundStopped:FireClient(player);

  end);
  
  error(message);

end;