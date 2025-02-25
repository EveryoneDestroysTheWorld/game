--!strict

export type ClientContestant = {
  
  id: number;

  archetypeID: string?;
  
  isDisqualified: boolean;

  player: Player?;

  characterName: string?;

  name: string;

  isBot: boolean;

  teamID: number?;

  currentHealth: number?;

  baseHealth: number?;

  currentStamina: number?;

  baseStamina: number?;

  -- statistics: TurfWarContestantStatistics?;
  
};

return {};