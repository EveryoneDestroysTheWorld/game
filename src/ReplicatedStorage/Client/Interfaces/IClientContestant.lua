--!strict

export type IClientContestant = {
  
  id: number;

  archetypeID: string?;
  
  isEliminated: boolean;

  player: Player?;

  characterName: string?;

  name: string;

  teamID: number?;

  currentHealth: number?;

  baseHealth: number?;

  currentStamina: number?;

  baseStamina: number?;
  
};

return {};