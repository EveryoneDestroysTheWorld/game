--!strict
-- This class represents a game mode on the server side.
--
-- Programmers: Christian Toney (Christian_Toney)

export type GameModeProperties = {
  id: string;
  name: string;
  description: string;
};

export type GameModeMethods = {
  start: (self: IGameMode) -> ();
  breakdown: (self: IGameMode) -> ();
}

export type IGameMode = GameModeProperties & GameModeMethods;

return {};