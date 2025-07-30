const Resolver = artifacts.require("Resolver");

const configs = {
    tron: {
        lop: "",
        escrowFactory: ""
    },
    nile: {
        lop: "TAYjAyuKjKvkhkcvgJ7CgrJ8PVziU5vr4R",
        escrowFactory: "THEb78FZnopZYvKpJvRcmicZLcewdmxURR"
    },
};

module.exports = function (deployer, network, accounts) {
    console.log("Deploying Resolver...");
    console.log("Network:", network);
    console.log("Deployer Account:", accounts);

    const initialOwner = accounts;

    console.log("----------------------------------------------------");
    console.log("Deploying EscrowFactory with the following arguments:");
    console.log(`  1. EscrowFactory:   ${configs[network].escrowFactory}`);
    console.log(`  2. LOP:             ${configs[network].lop}`);
    console.log("----------------------------------------------------");

    // Deploy the contract, passing all arguments in the correct order.
    deployer.deploy(
        Resolver,
        configs[network].escrowFactory,
        configs[network].lop,
        initialOwner,
    );
};
