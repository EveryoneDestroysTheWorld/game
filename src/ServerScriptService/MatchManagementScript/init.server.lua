--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local Stage = require(ServerStorage.Classes.Stage);
local Round = require(ServerStorage.Classes.Round);
local TurfWarGameMode = require(ServerStorage.Classes.GameModes.TurfWarGameMode);
local ServerContestant = require(ServerStorage.Classes.ServerContestant);

local expectedContestantIDs: {number} = {};
local contestants: {Player} = {};
local playerCheckThread: thread = nil;
local currentRound: Round.Round? = nil;

local function startRound()

  -- Disable the player check.
  task.cancel(playerCheckThread);

  -- Download a random stage from the stage list.
  local stage = Stage.random();
  local stageModel = stage:download();
  stageModel.Parent = workspace;

  -- Show the results when the round ends.
  local contestants = {};
  for _, player in ipairs(contestants) do

    table.insert(contestants, ServerContestant.new({
      ID = player.UserId;
      player = player;
      character = player.Character;
      archetypeID = 1;
      isDisqualified = false;
    }));

    task.spawn(function()
      
      -- TODO: Disqualify the player if this doesn't work.
      ReplicatedStorage.Shared.Functions.InitializeInventory:InvokeClient(player, 1);
    
    end)

  end;

  -- Create bot NPCs
  for i = 1, 4 - #contestants do

    -- Create the NPC's character.
    local character: Model = ServerStorage:FindFirstChild("NPCRigs"):FindFirstChild("Rig"):Clone();
    character.Name = "NPC" .. i;
    character.Parent = workspace;

    -- Add the NPC to the contestant list.
    table.insert(contestants, ServerContestant.new({
      ID = i * 0.01;
      character = character;
      archetypeID = 1;
      isDisqualified = false;
    }));
    
  end;

  ReplicatedStorage.Shared.Events.ResetButtonPressed.OnServerEvent:Connect(function(player)
  
    for _, contestant in ipairs(contestants) do

      if contestant.ID == player.UserId then

        contestant:disqualify();
        break;

      end

    end;

  end);

  local round = Round.new({
    stageID = stage.ID :: string;
    gameMode = TurfWarGameMode.new(stageModel, contestants);
    contestants = contestants;
    duration = 1500;
  });

  currentRound = round;
  
  round.onEnded:Connect(function()

    ReplicatedStorage.Shared.Events.RoundEnded:FireAllClients(round);

  end);

  -- Start the round.
  round:start(stageModel);
  print("Round started.");
  ReplicatedStorage.Shared.Events.RoundStarted:FireAllClients(120);

end;

local function checkPlayers()

  if #contestants == 0 then

    for _, player in ipairs(Players:GetPlayers()) do

      player:Kick("No contestant joined, so the match is off. :(");

    end;

  else

    -- The round hasn't started, so notify the rest of the participants that there are missing players.
    local disqualifiedContestantIDs = {};
    for _, expectedPlayerID in ipairs(expectedContestantIDs) do

      if not Players:GetPlayerByUserId(expectedPlayerID) then

        table.insert(disqualifiedContestantIDs, expectedPlayerID);

      end;

    end;

    startRound();

  end;

end;

playerCheckThread = task.delay(10, checkPlayers);

Players.PlayerAdded:Connect(function(player)

  if currentRound then

    player:Kick("Round is currently in session.");

  else

    local foundNewContestantID = false;
    for _, playerID in ipairs(expectedContestantIDs) do

      if playerID == player.UserId then

        table.insert(contestants, player);

      end;

      -- Check if we should start the round.
      local playerIDFound = false;
      for _, player in ipairs(contestants) do

        if playerID == player.UserId then
          
          playerIDFound = true;
          foundNewContestantID = true;
          break;

        end;

      end;

      if not playerIDFound then

        if foundNewContestantID then

          if playerCheckThread then

            task.cancel(playerCheckThread);

          end;
          playerCheckThread = task.delay(10, checkPlayers);

        end;

        return;

      end;

    end;
    
    startRound();

  end;

end);