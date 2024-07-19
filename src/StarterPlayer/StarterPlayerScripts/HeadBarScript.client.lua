local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local HeadBarContainer = require(ReplicatedStorage.Client.ReactComponents.HeadBarContainer);

local round = ClientRound.get();
local events = {};

local function addHeadBars()

  for _, contestant in ipairs(round.contestants) do

    if events[contestant] then

      events[contestant]:Disconnect();

    end;
    
    events[contestant] = contestant.onCharacterUpdated:Connect(function(character)
    
      local head = if character then character:FindFirstChild("Head") else nil;
      if head then
  
        local headBarContainerGUI = Instance.new("BillboardGui");
        headBarContainerGUI.AlwaysOnTop = true;
        headBarContainerGUI.MaxDistance = 50;
        headBarContainerGUI.Size = UDim2.new(5, 0, 1, 0);
        headBarContainerGUI.SizeOffset = Vector2.new(0, 2.5);
        headBarContainerGUI.Name = "HeadBarContainerGUI";
        headBarContainerGUI.Adornee = head;
        headBarContainerGUI.Parent = head;
        
        local headBarRoot = ReactRoblox.createRoot(headBarContainerGUI);
        headBarRoot:render(HeadBarContainer, {contestant = contestant});
  
      end;

    end);

  end;

end;

round.onContestantAdded:Connect(addHeadBars);

addHeadBars();