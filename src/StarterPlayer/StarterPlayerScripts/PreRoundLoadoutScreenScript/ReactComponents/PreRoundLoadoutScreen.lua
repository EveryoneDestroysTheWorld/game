--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local React = require(ReplicatedStorage.Shared.Packages.react);
local WaitingMessage = require(script.Parent.WaitingMessage);
local TransitionCircle = require(script.Parent.TransitionCircle);
local ContestantInformationContainer = require(script.Parent.ContestantInformationContainer);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
type RoundStatus = ClientRound.RoundStatus;
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local ActiveRoundNotification = require(script.Parent.ActiveRoundNotification);

local function PreRoundLoadoutScreen()

  local shouldShowTeams, setShouldShowTeams = React.useState(false);
  local roundStatus: RoundStatus?, setRoundStatus = React.useState(nil :: RoundStatus?);
  local teams, setTeams = React.useState({});
  local frameRef = React.useRef(nil :: Frame?);

  React.useEffect(function()
  
    task.spawn(function()
    
      local round = ClientRound.fromServerRound();
      round.onStatusChanged:Connect(function()
      
        setRoundStatus(round.status);

      end);

      local function updateTeams()

        local newTeams = {};

        for _, contestant in round.contestants do

          if not newTeams[contestant.teamID] then

            newTeams[contestant.teamID] = {};

          end;

          table.insert(newTeams[contestant.teamID], contestant);

        end;

        setTeams(newTeams);

      end;

      round.onContestantAdded:Connect(updateTeams);
      round.onContestantRemoved:Connect(updateTeams);

      setRoundStatus(round.status);

    end);

  end, {});

  React.useEffect(function()

    local frame = frameRef.current;
    if shouldShowTeams and frame then

      task.delay(2, function()
      
        local tween = TweenService:Create(frame, TweenInfo.new(), {
          BackgroundTransparency = 1;
        });

        tween.Completed:Once(function()
        
        end);

        tween:Play();

      end);

    end;

  end, {shouldShowTeams});

  return if roundStatus == "Active" then 
    React.createElement(ActiveRoundNotification)
  else
    React.createElement("Frame", {
      Size = UDim2.new(1, 0, 1, 0);
      BackgroundColor3 = if shouldShowTeams then Color3.new(1, 1, 1) else Color3.new(0, 0, 0);
      BorderSizePixel = 0;
      ref = frameRef;
    }, {
      ContestantInformationContainer = if shouldShowTeams then
        React.createElement(ContestantInformationContainer, {teams = teams})
      else nil;
      WaitingMessage = if not shouldShowTeams then
        React.createElement(WaitingMessage)
      else nil;
      TransitionCircle = if not shouldShowTeams then
        React.createElement(TransitionCircle, {
          roundStatus = roundStatus;
          onTransitionEnd = function()
            setShouldShowTeams(true);
          end;
        })
      else nil;
  });

end;

return PreRoundLoadoutScreen;