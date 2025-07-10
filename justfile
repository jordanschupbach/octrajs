clean:
  rm -rf build/
  rm -rf node_modules/

install:
  npm install

build:
  npm run build

dev:
  nix develop .

