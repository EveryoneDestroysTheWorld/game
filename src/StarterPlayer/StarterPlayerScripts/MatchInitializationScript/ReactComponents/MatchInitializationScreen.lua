--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local StarterGui = game:GetService("StarterGui");
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);
local player = Players.LocalPlayer;
local React = require(ReplicatedStorage.Shared.Packages.react);
local TeammateCard = require(script.Parent.TeammateCard);
local TeammateCardList = require(script.Parent.TeammateCardList);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local ArchetypeInformationFrame = require(script.Parent.ArchetypeInformationFrame);
local ArchetypeSelectionFrame = require(script.Parent.ArchetypeSelectionFrame);
local MatchInitializationHeader = require(script.Parent.MatchInitializationHeader);
local LoadingBackground = require(script.Parent.LoadingBackground);
local MatchInitializationTimer = require(script.Parent.MatchInitializationTimer);

local function MatchInitializationScreen()

  -- Disable the StarterGui to follow DemoDemons' UI aesthetic for full-screen windows.
  React.useEffect(function()
  
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false);

    return function()

      StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true);

    end;

  end, {});

  -- Get teammate cards to show to the player.
  local round = React.useState(ClientRound.fromServerRound());
  local shouldShowArchetypeInformation, setShouldShowArchetypeInformation = React.useState(false);
  local selectedArchetype: ClientArchetype, setSelectedArchetype = React.useState(nil :: ClientArchetype?);
  local contestants, setContestants = React.useState(round.contestants :: {ClientContestant});

  local function getTeamListCards()

    local newAllyTeammateCards = {};
    local newRivalTeammateCards = {};

    local ownTeamID: number?;
    for _, contestant in contestants do

      if contestant.ID == player.UserId then

        ownTeamID = contestant.teamID;
        break;

      end;

    end;

    for _, contestant in contestants do

      local isRival = contestant.ID ~= player.UserId and not ownTeamID or contestant.teamID ~= ownTeamID;
      local selectedTable = if isRival then newRivalTeammateCards else newAllyTeammateCards;
      local teammateCard = React.createElement(TeammateCard, {
        contestant = contestant;
        isRival = isRival;
        layoutOrder = #selectedTable + 1;
        round = round;
      })

      table.insert(selectedTable, teammateCard);

    end;

    -- Fill in the blank slots.
    for ti, t in {newAllyTeammateCards, newRivalTeammateCards} do

      for i = #t + 1, 4 do

        table.insert(t, React.createElement(TeammateCard, {
          isRival = ti == 2;
          layoutOrder = i;
        }))

      end;

    end;

    return newAllyTeammateCards, newRivalTeammateCards;

  end;

  local allyTeammateCards, rivalTeammateCards = getTeamListCards();

  React.useEffect(function(): ()

    if round then

      -- Get the current list of teams.
      local function updateContestants()

        setContestants(round.contestants);

      end;
    
      -- Listen for updates.
      local e1 = round.onContestantAdded:Connect(updateContestants);
      local e2 = round.onContestantRemoved:Connect(updateContestants);

      local function checkRoundStatus()

        setShouldShowArchetypeInformation(round.status == "Contestant selection");

      end;
      
      local e3 = round.onStatusChanged:Connect(checkRoundStatus);
      checkRoundStatus();

      return function()

        e1:Disconnect();
        e2:Disconnect();
        e3:Disconnect();

      end;

    end;

  end, {round});

  local backgroundTransparency, setBackgroundTransparency = React.useState(0.4);
  React.useEffect(function()
  
    local characterAddedEvent = Players.LocalPlayer.CharacterAdded:Connect(function()
    
      dataTypeTween({
        type = "Number";
        initialValue = backgroundTransparency;
        goalValue = 1;
        onChange = function(newValue)

          setBackgroundTransparency(newValue);

        end;
      }):Play();

    end);

    return function()

      characterAddedEvent:Disconnect();

    end;

  end, {});

  local isConfirmingArchetype, setIsConfirmingArchetype = React.useState(false);

  return React.createElement("Frame", {
    BackgroundTransparency = backgroundTransparency;
    BackgroundColor3 = Color3.fromRGB(4, 4, 4);
    BorderSizePixel = 0;
    Size = UDim2.new(1, 0, 1, 0);
  }, {
    MainContainer = React.createElement("Frame", {
      BackgroundTransparency = 1;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 2;
    }, {
      UIPadding = React.createElement("UIPadding", {
        PaddingBottom = UDim.new(0, 15);
        PaddingLeft = UDim.new(0, 15);
        PaddingRight = UDim.new(0, 15);
        PaddingTop = UDim.new(0, 15);
      });
      MatchInitializationTimerFrame = React.createElement(MatchInitializationTimer);
      Header = if round then React.createElement(MatchInitializationHeader, {round = round}) else nil;
      Content = React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        LayoutOrder = 2;
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.new(1, 0, 0, 0);
      }, {
        AllyTeammateCardList = React.createElement(TeammateCardList, {
          layoutOrder = 1;
          round = round;
        }, allyTeammateCards);
        RivalTeammateCardList = React.createElement(TeammateCardList, {
          layoutOrder = 2;
          round = round;
          shouldHide = shouldShowArchetypeInformation;
        }, rivalTeammateCards);
        ArchetypeInformationFrame = React.createElement(ArchetypeInformationFrame, {
          selectedArchetype = selectedArchetype;
          shouldHide = not shouldShowArchetypeInformation;
        });
      });
      ArchetypeSelectionFrame = if shouldShowArchetypeInformation then React.createElement(ArchetypeSelectionFrame, {
        isConfirmingArchetype = isConfirmingArchetype;
        selectedArchetype = selectedArchetype;
        onSelectionChanged = function(newSelectedArchetype)

          setSelectedArchetype(newSelectedArchetype);

        end;
        onSelectionConfirmed = function()

          setIsConfirmingArchetype(true);

          local didConfirmArchetype, errorMessage = pcall(function()
            
            ReplicatedStorage.Shared.Functions.ChooseArchetype:InvokeServer(selectedArchetype.ID);

          end);

          if not didConfirmArchetype then

            warn(`Couldn't confirm archetype: {errorMessage}`);
            setIsConfirmingArchetype(false);

          end;

        end;
      }) else nil;
    });
    LoadingBackground = if round then React.createElement(LoadingBackground, {round = round}) else nil;
    -- MainStatus = React.createElement("TextLabel", {
    --   Text = "GET READY!";
    --   AutomaticSize = Enum.AutomaticSize.XY;
    --   BackgroundTransparency = 1;
    --   TextTransparency = 1;
    --   AnchorPoint = Vector2.new(0.5, 0.5);
    --   FontFace = Font.fromId(16658221428, Enum.FontWeight.ExtraBold);
    --   Position = UDim2.new(0.5, 0, 0.5, 0);
    --   Visible = false;
    -- }, {
    --   UIStroke = React.createElement("UIStroke", {
    --     Transparency = 0.41;
    --     Thickness = 1;
    --   })
    -- });
  });

end;

return MatchInitializationScreen;