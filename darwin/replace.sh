#!/bin/bash
find . -type f -name "*.nix" -exec sed -i '' "s/{user}/yourusername/g" {} +
find . -type f -name "*.nix" -exec sed -i '' "s/{username}/yourgithubusername/g" {} +
find . -type f -name "*.nix" -exec sed -i '' "s/{email}/your@email.com/g" {} +

echo "Replaced placeholders!"