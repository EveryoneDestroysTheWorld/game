--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local HeadBarContainer = require(ReplicatedStorage.Client.ReactComponents.HeadBarContainer);
local Players = game:GetService("Players");

local types = require(ReplicatedStorage.Client.Modules.types);

local round = ClientRound.fromServerRound();
local events = {};

local function initializeContestant(contestant: types.ClientContestant): ()

  if contestant.player and contestant.player == Players.LocalPlayer then

    return;

  end;

  if events[contestant] then

    events[contestant]:Disconnect();

  end;

  local function addHeadBars(character: Model?): ()

    local head = if character then character:FindFirstChild("Head") else nil;
    if head and not head:FindFirstChild("HeadBarContainerGUI") then

      local headBarContainerGUI = Instance.new("BillboardGui");
      headBarContainerGUI.AlwaysOnTop = true;
      headBarContainerGUI.MaxDistance = 100;
      headBarContainerGUI.Size = UDim2.new(5, 0, 1, 0);
      headBarContainerGUI.SizeOffset = Vector2.new(0, 2.5);
      headBarContainerGUI.Name = "HeadBarContainerGUI";
      headBarContainerGUI.Adornee = head;
      headBarContainerGUI.Parent = head;
      
      local headBarRoot = ReactRoblox.createRoot(headBarContainerGUI);
      headBarRoot:render(React.createElement(HeadBarContainer, {contestant = contestant}));

    end;

  end;

  events[contestant] = contestant.onCharacterUpdated:Connect(function(character)
  
    addHeadBars(character);

  end);

  addHeadBars(contestant.character);

end;

round.onContestantAdded:Connect(function(contestantID)

  for _, contestant in round:getContestants() do

    if contestant.id == contestantID then

      initializeContestant(contestant);

    end;

  end;

end);

for _, contestant in round:getContestants() do
  
  initializeContestant(contestant);

end;