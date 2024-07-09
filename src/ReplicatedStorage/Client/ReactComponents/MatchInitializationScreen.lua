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

local function MatchInitializationScreen()

  -- Disable the StarterGui to follow DemoDemons' UI aesthetic for full-screen windows.
  React.useEffect(function()
  
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false);

    return function()

      StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true);

    end;

  end, {});

  -- Get teammate cards to show to the player.
  -- local allyTeammateCards, setAllyTeammateCards = React.useState({});
  -- local rivalTeammateCards, setRivalTeammateCards = React.useState({});
  -- React.useEffect(function()

  --   -- Get the current list of teams.
  --   local function updateTeamLists()

  --     local teams = ReplicatedStorage.Shared.Functions.GetTeams:Invoke();
  --     for _, team in ipairs(teams) do

  --       -- Distinguish rival teams.
  --       local isRivalTeam = true;
  --       for _, teammate in ipairs(team.members) do

  --         if teammate.player and teammate.player == player then

  --           isRivalTeam = false;
  --           break

  --         end;
          
  --       end;

  --       local teammateCards = {};
  --       for index, teammate in ipairs(team.members) do

  --         table.insert(teammateCards, React.createElement(TeammateCard, {
  --           contestant = teammate;
  --           isRival = isRivalTeam;
  --           layoutOrder = index;
  --         }));

  --       end;

  --       if isRivalTeam then

  --         setRivalTeammateCards(rivalTeammateCards);

  --       else

  --         setAllyTeammateCards(teammateCards);

  --       end;

  --     end;

  --   end;
  --   updateTeamLists();
   
  --   -- Listen for updates.
  --   ReplicatedStorage.Shared.Events.TeamMemberAdded.OnClientEvent:Connect(updateTeamLists);
  --   ReplicatedStorage.Shared.Events.TeamMemberRemoved.OnClientEvent:Connect(updateTeamLists);

  -- end, {});

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
        UIListLayout = React.createElement("UIListLayout", {
          SortOrder = Enum.SortOrder.LayoutOrder;
          FillDirection = Enum.FillDirection.Horizontal;
          HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween;
        });
        GameModeDescriptionFrame = React.createElement("Frame", {
          BackgroundTransparency = 1;
          AutomaticSize = Enum.AutomaticSize.XY;
          LayoutOrder = 1;
          Size = UDim2.new();
        }, {
          UIListLayout = React.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
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
        MatchInitializationTimerFrame = React.createElement(MatchInitializationTimer, {
          layoutOrder = 2;
        });
      });
    --   Content = React.createElement("Frame", {
    --     AutomaticSize = Enum.AutomaticSize.Y;
    --     BackgroundTransparency = 1;
    --     LayoutOrder = 2;
    --     AnchorPoint = Vector2.new(0.5, 0.5);
    --     Position = UDim2.new(0.5, 0, 0.5, 0);
    --     Size = UDim2.new(1, 0, 0, 0);
    --   }, {
    --     UIListLayout = React.createElement("UIListLayout", {
    --       SortOrder = Enum.SortOrder.LayoutOrder;
    --       HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween;
    --     });
    --     AllyTeammateCardList = React.createElement(TeammateCardList, {
    --       layoutOrder = 1;
    --     }, allyTeammateCards);
    --     RivalTeammateCardList = React.createElement(TeammateCardList, {
    --       layoutOrder = 2;
    --     }, rivalTeammateCards);
    --   });
    });
    Ticker = React.createElement(Ticker);
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