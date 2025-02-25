--!strict
-- This module represents an Archetype, which contains a list of powers.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

export type RoundStatus = "Waiting for players" | "Contestant selection" | "Matchup preview" | "Initializing character models" | "Pre-round countdown" | "Active";

export type ClientRound = {

  id: string;  
  
  stageID: string;

  timeStarted: number?;

  duration: number?;

  timeEnded: number?;

  status: RoundStatus;
  
  contestantIDs: {number};

}

return {};