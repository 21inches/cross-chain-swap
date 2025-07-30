const EscrowFactory = artifacts.require("EscrowFactory");

const configs = {
    tron: {
        lop: "",
        feeToken: "",
        accessToken: ""
    },
    nile: {
        lop: "TAYjAyuKjKvkhkcvgJ7CgrJ8PVziU5vr4R",
        feeToken: "TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf", // USDT on Nile
        accessToken: "TUdoqfVVJviAdDYMgJPSnGbfVo64eyq2D1"

    },
};

module.exports = function (deployer, network, accounts) {
    console.log("Deploying Escrow...");
    console.log("Network:", network);
    console.log("Accounts:", accounts[0]);

    // 4. Fee Bank Owner
    const feeBankOwnerAddress = accounts;

    // 5. & 6. Rescue Delay (8 days in seconds)
    const rescueDelay = 691200;

    console.log("----------------------------------------------------");
    console.log("Deploying EscrowFactory with the following arguments:");
    console.log(`  1. LOP:             ${configs[network].lopAddress}`);
    console.log(`  2. Fee Token:       ${configs[network].feeTokenAddress}`);
    console.log(`  3. Access Token:    ${configs[network].accessTokenAddress}`);
    console.log(`  4. Fee Bank Owner:  ${feeBankOwnerAddress}`);
    console.log(`  5. Rescue Delay 1:  ${rescueDelay}`);
    console.log(`  6. Rescue Delay 2:  ${rescueDelay}`);
    console.log("----------------------------------------------------");

    // Deploy the contract, passing all arguments in the correct order.
    deployer.deploy(
        EscrowFactory,
        configs[network].lopAddress,
        configs[network].feeTokenAddress,
        configs[network].accessTokenAddress,
        feeBankOwnerAddress,
        rescueDelay,
        rescueDelay
    );
};
