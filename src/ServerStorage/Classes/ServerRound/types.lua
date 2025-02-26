--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientRound = require(ReplicatedStorage.Client.Interfaces.ClientRound);

export type RoundStatus = ClientRound.RoundStatus;

export type ServerRoundProperties = ClientRound.ClientRound

export type ServerRoundMethods = {

  --[[
    Adds a contestant to the round.
  ]]
  addContestant: (self: ServerRound, contestantID: number) -> ();

  --[[
    Converts the current server round to a client object, stripping any sensitive data.
  ]]
  convertToClientRound: (self: ServerRound) -> ClientRound.ClientRound;

  setStatus: (self: ServerRound, status: ClientRound.RoundStatus) -> ();

  start: (self: ServerRound) -> ();

  stop: (self: ServerRound, forced: boolean?) -> ();

  setGameModeID: (self: ServerRound, gameModeID: string) -> ();
}

export type ServerRound = ServerRoundProperties & ServerRoundMethods;

return {};