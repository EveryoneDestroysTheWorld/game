# Everyone Destroys the World
Everyone Destroys the World is a battle game by Beastslash where you get magical powers and items to wreck the stage and win. 

## 🎞️ Credits
This game is being developed and published by Beastslash. To see a full list of people on the Everyone Destroys the World Team and outside contributors, see [CONTRIBUTORS.md](./CONTRIBUTORS.md).

## 🚧 Development
### Logistics
#### Ensure that the issue exists in the game repository
All pull requests should be based on design implementations and bug fixes. Please ensure that the design information exists in the [`design` repository](https://github.com/EveryoneDestroysTheWorld/design) before starting development on features. If it doesn't exist, propose it using the issues section in the design repository. After the feature is designed, ensure that the implementation issue exists on this repository.

#### Creating a branch
Use the `staging` branch to get the most stable version of the game. When the game is released, the most stable version will be on the `production` branch.

### Install dependencies
The following dependencies are required for development:
* [Roblox Studio](https://create.roblox.com/docs/studio/setting-up-roblox-studio) - This game is developed on Roblox.
* [Aftman](https://github.com/LPGhatguy/aftman/releases) - Required to install Wally.
* [Wally](https://wally.run/install) - Required to install Luau packages.

### Create a development place
You can create a development place by copying the [staging place](https://www.roblox.com/games/17711502472/Everyone-Destroys-the-World-Staging-Game) into a new game on your personal account. 

> [!WARNING]
> Do not directly develop on the staging place.

### Implement changes
Enable Rojo and use `development.project.json`. Go ahead and implement whatever the issue needs. Be sure to include any models as `.rbxlx` or `.model.json` files if you create any.

### Publish changes
Submit a [pull request](https://github.com/EveryoneDestroysTheWorld/game/pulls) that merges your branch into `staging`. Link the implementation issue if it's already not linked.

> [!IMPORTANT]
> The `staging` branch is automatically published to Roblox. There are branch protections in place, but if you can directly commit to `staging`, avoid doing so.

## See also
* [Stage Maker repository](https://github.com/EveryoneDestroysTheWorld/stage-maker)
* [Lobby repository](https://github.com/EveryoneDestroysTheWorld/lobby)
