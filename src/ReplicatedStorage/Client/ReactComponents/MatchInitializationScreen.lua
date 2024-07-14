--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local player = Players.LocalPlayer;
local React = require(ReplicatedStorage.Shared.Packages.react);
local StarterGui = game:GetService("StarterGui");
local Ticker = require(script.Parent.Ticker);
local MatchInitializationTimer = require(script.Parent.MatchInitializationTimer);
local TeammateCard = require(script.Parent.TeammateCard);
local TeammateCardList = require(script.Parent.TeammateCardList);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ArchetypeInformationFrame = require(script.Parent.ArchetypeInformationFrame);
local TweenService = game:GetService("TweenService");

local function MatchInitializationScreen()

  -- Disable the StarterGui to follow DemoDemons' UI aesthetic for full-screen windows.
  React.useEffect(function()
  
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false);

    return function()

      StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true);

    end;

  end, {});

  -- Get teammate cards to show to the player.
  local allyTeammateCards, setAllyTeammateCards = React.useState({});
  local rivalTeammateCards, setRivalTeammateCards = React.useState({});
  local round, setRound = React.useState(nil :: ClientRound?);
  local shouldShowArchetypeInformation, setShouldShowArchetypeInformation = React.useState(false);
  React.useEffect(function()
  
    local roundConstructorProperties = ReplicatedStorage.Shared.Functions.GetRound:InvokeServer();
    local round = ClientRound.new(roundConstructorProperties);
    setRound(round);
    
  end, {});

  React.useEffect(function()

    if round then

      -- Get the current list of teams.
      local function updateTeamLists()

        local newAllyTeammateCards = {};
        local newRivalTeammateCards = {};

        local ownTeamID: number?;
        for _, contestant in ipairs(round.contestants) do

          if contestant.ID == player.UserId then

            ownTeamID = contestant.teamID;
            break;

          end;

        end;

        for _, contestant in ipairs(round.contestants) do

          local isRival = contestant.ID ~= player.UserId and not ownTeamID or contestant.teamID ~= ownTeamID;
          local selectedTable = if isRival then newRivalTeammateCards else newAllyTeammateCards;
          local teammateCard = React.createElement(TeammateCard, {
            contestant = contestant;
            isRival = isRival;
            layoutOrder = #selectedTable;
            round = round;
          })

          table.insert(selectedTable, teammateCard);

        end;

        for ti, t in ipairs({newAllyTeammateCards, newRivalTeammateCards}) do

          for i = #t + 1, 4 do

            table.insert(t, React.createElement(TeammateCard, {
              isRival = ti == 2;
              layoutOrder = i;
            }))

          end;

        end;

        setAllyTeammateCards(newAllyTeammateCards);
        setRivalTeammateCards(newRivalTeammateCards);

      end;

      -- Use task.spawn to prevent blocking of other effects.
      task.spawn(function() updateTeamLists() end);
    
      -- Listen for updates.
      round.onContestantAdded:Connect(updateTeamLists);
      round.onContestantRemoved:Connect(updateTeamLists);

      local function checkRoundStatus()

        setShouldShowArchetypeInformation(round.status == "Contestant selection");

      end;
      
      round.onStatusChanged:Connect(checkRoundStatus);
      checkRoundStatus();

    end;

  end, {round});

  local uiPaddingRightOffset, setUIPaddingRightOffset = React.useState(0);
  React.useEffect(function()
  
    local numberValue = Instance.new("NumberValue");
    numberValue:GetPropertyChangedSignal("Value"):Connect(function()
      
      setUIPaddingRightOffset(numberValue.Value);

    end);
    
    local goalTransparency = if shouldShowArchetypeInformation then -300 else 0;
    local tween = TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = goalTransparency});
    tween:Play();

  end, {shouldShowArchetypeInformation});

  return React.createElement("Frame", {
    BackgroundTransparency = 0.4;
    BackgroundColor3 = Color3.fromRGB(4, 4, 4);
    BorderSizePixel = 0;
    Size = UDim2.new(1, 0, 1, 0);
  }, {
    MainContainer = React.createElement("Frame", {
      BackgroundTransparency = 1;
      Size = UDim2.new(1, 0, 1, 0);
    }, {
      UIPadding = React.createElement("UIPadding", {
        PaddingBottom = UDim.new(0, 30);
        PaddingLeft = UDim.new(0, 30);
        PaddingRight = UDim.new(0, 30);
        PaddingTop = UDim.new(0, 30);
      });
      Header = React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 0, 0);
      }, {
        GameModeDescriptionFrame = React.createElement("Frame", {
          BackgroundTransparency = 1;
          AutomaticSize = Enum.AutomaticSize.XY;
          LayoutOrder = 1;
          Position = UDim2.new(0.5, 0, 0, 0);
          AnchorPoint = Vector2.new(0.5, 0);
          Size = UDim2.new();
        }, {
          UIListLayout = React.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
            Padding = UDim.new(0, 5);
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
          });
          SubtitleLabel = React.createElement("TextLabel", {
            BackgroundTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.XY;
            Size = UDim2.new();
            Text = "YOU'RE IN A";
            LayoutOrder = 1;
            FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 14;
          });
          GameModeLabel = React.createElement("TextLabel", {
            BackgroundTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.XY;
            Size = UDim2.new();
            Text = "TURF WAR";
            LayoutOrder = 2;
            FontFace = Font.fromId(11702779517, Enum.FontWeight.Heavy);
            TextColor3 = Color3.fromRGB(255, 94, 97);
            TextSize = 30;
          });
          TaglineLabel = React.createElement("TextLabel", {
            BackgroundTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.XY;
            Size = UDim2.new();
            LayoutOrder = 3;
            Text = "The rules are simple: destroy everything before they do";
            FontFace = Font.fromId(11702779517);
            TextColor3 = Color3.fromRGB(199, 199, 199);
            TextSize = 18;
          });
        });
        MatchInitializationTimerFrame = React.createElement(MatchInitializationTimer);
      });
      Content = React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        LayoutOrder = 2;
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.new(1, 0, 0, 0);
      }, {
        UIPadding = React.createElement("UIPadding", {
          PaddingRight = UDim.new(0, uiPaddingRightOffset);
        });
        AllyTeammateCardList = React.createElement(TeammateCardList, {
          layoutOrder = 1;
        }, allyTeammateCards);
        RivalTeammateCardList = React.createElement(TeammateCardList, {
          layoutOrder = 2;
          uiPaddingRightOffset = uiPaddingRightOffset;
        }, rivalTeammateCards);
        ArchetypeInformationFrame = React.createElement(ArchetypeInformationFrame, {
          uiPaddingRightOffset = uiPaddingRightOffset;
        });
      });
    });
    Ticker = React.createElement(Ticker, {round = round});
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