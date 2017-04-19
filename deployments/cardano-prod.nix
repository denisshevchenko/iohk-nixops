with (import ./../lib.nix);

let
  conf = { config, pkgs, resources, ... }: {
    imports = [
      ./../modules/datadog.nix
      ./../modules/papertrail.nix
    ];

    # Initial block is big enough to hold 3 months of transactions
    deployment.ec2.ebsInitialRootDiskSize = mkForce 700;

    services.dd-agent.tags = ["env:production"];
    services.dd-agent.processConfig = ''
      instances:
        - name: cardano-node
          search_string: ['cardano-node']
          thresholds:
            critical: [1, 2]
    '';
  };
in {
  report-server = conf;
} // (genAttrs' (range 0 13) (key: "node${toString key}") (name: conf))
