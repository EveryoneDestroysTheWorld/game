--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local TeleportService = game:GetService("TeleportService");
local HttpService = game:GetService("HttpService");
local Stage = require(ServerStorage.Classes.Stage);
local ServerRound = require(ServerStorage.Classes.ServerRound);
local TurfWarGameMode = require(ServerStorage.Classes.GameModes.TurfWarGameMode);
local ServerContestant = require(ServerStorage.Classes.ServerContestant);

-- Get the match info.
local expectedPlayerIDs = {904459813};
local playerCheck = task.delay(10, function()

  -- The round hasn't started, so kick everyone back to the lobby.
  TeleportService:TeleportAsync(15555144468, Players:GetPlayers());

end);

-- Download a random stage from the stage list.
local stage;
local shouldGetRandomStage = true;
if game.PrivateServerId then

  stage = Stage.fromPrivateServerID(game.PrivateServerId)

elseif shouldGetRandomStage then

  -- This should only happen during test times.
  stage = Stage.random();

else

  error("This isn't a private server.");

end;

local stageModel = stage:download();
stageModel.Parent = workspace;

-- Initialize the round.
local round = ServerRound.new({
  ID = HttpService:GenerateGUID();
  stageID = stage.ID :: string;
  contestants = {};
  duration = 1500;
});

round:setGameMode(TurfWarGameMode.new(stageModel, round));

ReplicatedStorage.Shared.Functions.GetRound.OnServerInvoke = function()

  assert(round, "The server hasn't initialized the round yet.");

  -- Convert the ServerRound to a ClientRound.
  return round:getClientConstructorProperties();

end;

local function startRound()

  -- Disable the player check.
  task.cancel(playerCheck);

  -- Create bot NPCs
  -- for i = 1, 4 - #contestants do

  --   -- Create the NPC's character.
  --   local character: Model = ServerStorage:FindFirstChild("NPCRigs"):FindFirstChild("Rig"):Clone();
  --   character.Name = "NPC" .. i;
  --   character.Parent = workspace;

  --   -- Add the NPC to the contestant list.
  --   table.insert(contestants, ServerContestant.new({
  --     ID = i * 0.01;
  --     character = character;
  --     archetypeID = 1;
  --     isDisqualified = false;
  --   }));

  -- end;

  ReplicatedStorage.Shared.Events.ResetButtonPressed.OnServerEvent:Connect(function(player)
  
    for _, contestant in ipairs(round.contestants) do

      if contestant.ID == player.UserId then

        contestant:disqualify();
        break;

      end

    end;

  end);

  round.onEnded:Connect(function()

    ReplicatedStorage.Shared.Events.RoundEnded:FireAllClients(round);

  end);

  -- Start the round.
  round:start(stageModel);
  print("Round started.");
  ReplicatedStorage.Shared.Events.RoundStarted:FireAllClients(120);

end;

local function checkPlayerList(player: Player)

  for _, playerID in ipairs(expectedPlayerIDs) do

    if playerID == player.UserId then

      round:addContestant(ServerContestant.new({
        ID = player.UserId;
        player = player;
        character = player.Character;
        archetypeID = 1;
        isDisqualified = false;
      }));

    end;

    -- task.spawn(function()
      
    --   -- TODO: Disqualify the player if this doesn't work.
    --   ReplicatedStorage.Shared.Functions.InitializeInventory:InvokeClient(player, 1);
    
    -- end)

    -- Check if we should start the round.
    local playerIDFound = false;
    for _, contestant in ipairs(round.contestants) do

      if playerID == contestant.ID then
        
        playerIDFound = true;
        break;

      end;

    end;

    if not playerIDFound then

      return;

    end;

  end;

  -- startRound();

end;

Players.PlayerAdded:Connect(function(player)

  checkPlayerList(player);

end);

for _, player in ipairs(Players:GetPlayers()) do

  checkPlayerList(player);

end;