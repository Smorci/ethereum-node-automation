{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = with pkgs; mkShell {
          buildInputs = [ fluxcd fluxctl kind kubectx kubectl openssl ];
        };

        packages = rec {
          default = with pkgs; writeShellApplication {
            name = "bootstrap-ethereum-cluster";

            runtimeInputs = [ kind fluxcd kubectl kubectx openssl ];

            text = ''
              set -e

              # shellcheck source=/dev/null
              source .env

              kind create cluster --name ethereum-nodes

              kubectl create namespace ethereum-node-automation

              kubens ethereum-node-automation

              # shellcheck source=/dev/null
              source scripts/generate-token.sh
              
              flux bootstrap github \
                --owner=Smorci \
                --repository=ethereum-node-automation \
                --branch=main \
                --path=./clusters/ethereum-node-automation \
                --personal

              flux create source git ethereum-node-automation \
                --url=https://github.com/Smorci/ethereum-node-automation \
                --branch=main \
                --interval=1m \
                --export > ./clusters/ethereum-node-automation/ethereum-node-automation-source.yaml

              flux create kustomization ethereum-node-automation \
                --target-namespace=ethereum-node-automation \
                --source=ethereum-node-automation \
                --path=./kustomize \
                --prune=true \
                --wait=true \
                --interval=30m \
                --retry-interval=2m \
                --health-check-timeout=3m \
                --export > ./clusters/ethereum-node-automation/ethereum-node-automation-kustomization.yaml
            '';

              };
          delete = with pkgs; writeShellApplication {
            name = "delete-ethereum-cluster";

            runtimeInputs = [ kind ];

            text = ''
              set -e

              kind delete clusters ethereum-nodes
            '';
          };
          };
        }
    );
}
