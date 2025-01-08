--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local StatContainer = require(script.Parent.StatContainer);
local Button = require(ReplicatedStorage.Client.ReactComponents.Button);
local Players = game:GetService("Players");

type RoundTimerProps = {
  round: ClientRound;
}

local function ArchetypeStatsContainer(props: RoundTimerProps)

  local focusedContestant;
  for _, contestant in props.round.contestants do

    if contestant.player == Players.LocalPlayer then

      focusedContestant = contestant;
      break;

    end;

  end;

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 1);
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.Y;
    Position = UDim2.new(0.5, 0, 1, -30);
    Size = UDim2.new(0, 200, 0, 0);
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
    });
    StatsContainer = if focusedContestant then
      React.createElement("Frame", {
        LayoutOrder = 1;
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 0, 20);
      }, {
        UIListLayout = React.createElement("UIListLayout", {
          SortOrder = Enum.SortOrder.LayoutOrder;
          Padding = UDim.new(0, 5);
          FillDirection = Enum.FillDirection.Horizontal;
        });
        HealthStatContainer = React.createElement(StatContainer, {
          iconImage = "rbxassetid://89195253844423",
          layoutOrder = 1;
          value = focusedContestant.currentHealth;
        });
        StaminaStatContainer = React.createElement(StatContainer, {
          iconImage = "rbxassetid://124027369520548",
          layoutOrder = 2;
          value = focusedContestant.currentStamina;
        });
      })
    else nil;
    ArchetypeButton = React.createElement(Button, {
      LayoutOrder = 2;
      Text = "CHOOSE AN ARCHETYPE";
      [React.Event.Activated] = function()


      end;
    });
  });

end;

return ArchetypeStatsContainer;