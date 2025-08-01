const EscrowFactory = artifacts.require("EscrowFactory");

const configs = {
    tron: {
        lop: "",
        feeToken: "",
        accessToken: ""
    },
    nile: {
        lop: "TSPJQgvNRyEE7fQCdQdRSpS8GjFANP9GxM",
        feeToken: "TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf", // USDT on Nile
        accessToken: "TUdoqfVVJviAdDYMgJPSnGbfVo64eyq2D1"
    },
};

module.exports = function (deployer, network, accounts) {
    console.log("Deploying Escrow...");
    console.log("Network:", network);
    console.log("Deployer Account:", accounts);

    const feeBankOwnerAddress = accounts;

    // 5. & 6. Rescue Delay (8 days in seconds)
    const rescueDelay = 691200;

    console.log("----------------------------------------------------");
    console.log("Deploying EscrowFactory with the following arguments:");
    console.log(`  1. LOP:             ${configs[network].lop}`);
    console.log(`  2. Fee Token:       ${configs[network].feeToken}`);
    console.log(`  3. Access Token:    ${configs[network].feeToken}`);
    console.log(`  4. Fee Bank Owner:  ${feeBankOwnerAddress}`);
    console.log(`  5. Rescue Delay 1:  ${rescueDelay}`);
    console.log(`  6. Rescue Delay 2:  ${rescueDelay}`);
    console.log("----------------------------------------------------");

    // Deploy the contract, passing all arguments in the correct order.
    deployer.deploy(
        EscrowFactory,
        configs[network].lop, // Corrected
        configs[network].feeToken, // Corrected
        configs[network].feeToken, // Corrected
        feeBankOwnerAddress,
        rescueDelay,
        rescueDelay
    );
};
