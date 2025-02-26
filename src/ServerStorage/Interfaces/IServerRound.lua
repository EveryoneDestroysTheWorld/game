--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local ClientRound = require(ReplicatedStorage.Client.Interfaces.IClientRound);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);

type IServerContestant = IServerContestant.IServerContestant;

export type RoundStatus = ClientRound.RoundStatus;

export type IServerRoundProperties = ClientRound.ClientRound;

export type IServerRoundMethods = {

  --[[
    Adds a contestant to the round.
  ]]
  addContestant: (self: IServerRound, contestantID: number) -> ();

  --[[
    Converts the current server round to a client object, stripping any sensitive data.
  ]]
  convertToClientRound: (self: IServerRound) -> ClientRound.ClientRound;

  setStatus: (self: IServerRound, status: ClientRound.RoundStatus) -> ();

  setGameModeID: (self: IServerRound, gameModeID: string) -> ();

  getContestants: (self: IServerRound) -> {IServerContestant};

}

export type IServerRound = IServerRoundProperties & IServerRoundMethods;

return {};