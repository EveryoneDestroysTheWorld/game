--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local StatContainer = require(script.Parent.StatContainer);
local Button = require(ReplicatedStorage.Client.ReactComponents.Button);
local Players = game:GetService("Players");

type RoundTimerProps = {
  round: ClientRound;
}

local function ArchetypeStatsContainer(props: RoundTimerProps)

  local contestant, setContestant = React.useState(nil :: ClientContestant?);
  local archetypeName: string?, setArchetypeName = React.useState(nil :: string?);

  React.useEffect(function()
  
    task.spawn(function()

      local focusedContestant: ClientContestant?;
      for _, contestant in props.round.contestants do

        if contestant.player == Players.LocalPlayer then

          focusedContestant = contestant;
          break;

        end;

      end;

      setContestant(focusedContestant);

      if focusedContestant then

        local function updateArchetypeName()

          if focusedContestant and focusedContestant.archetypeID then
      
            local archetype = ClientArchetype.get(focusedContestant.archetypeID);
            setArchetypeName(archetype.name);
      
          else
      
            setArchetypeName(nil);
      
          end;

          ReplicatedStorage.Client.Functions.ToggleSelector:Invoke(false);
      
        end;

        focusedContestant.onArchetypeUpdated:Connect(updateArchetypeName);
        updateArchetypeName();

      end;

    end);

  end, {props.round});

  return if contestant then
    React.createElement("Frame", {
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
      StatsContainer = if contestant then
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
            contestant = contestant;
          });
          StaminaStatContainer = React.createElement(StatContainer, {
            iconImage = "rbxassetid://124027369520548",
            layoutOrder = 2;
            contestant = contestant;
          });
        })
      else nil;
      ArchetypeButton = React.createElement(Button, {
        LayoutOrder = 2;
        Text = if archetypeName then archetypeName:upper() else "CHOOSE AN ARCHETYPE";
        [React.Event.Activated] = function()

          ReplicatedStorage.Client.Functions.ToggleSelector:Invoke(true);

        end;
      });
    })
  else nil;

end;

return ArchetypeStatsContainer;