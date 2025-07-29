const EscrowFactory = artifacts.require("EscrowFactory");

module.exports = function (deployer, network, accounts) {
    console.log("Deploying Escrow...");
    console.log("Network:", network);
    console.log("Accounts:", accounts[0]);

    const lopAddress = "TAYjAyuKjKvkhkcvgJ7CgrJ8PVziU5vr4R";

    // 2. Fee Token Address (Using USDT for Nile)
    const feeTokenAddress = "TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf"; // TODO

    // 3. Access Token Address (0xACCe... converted to Base58)
    const accessTokenAddress = "TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf"; // TODO

    // 4. Fee Bank Owner
    const feeBankOwnerAddress = accounts; // TODO

    // 5. & 6. Rescue Delay (8 days in seconds)
    const rescueDelay = 691200;

    console.log("----------------------------------------------------");
    console.log("Deploying EscrowFactory with the following arguments:");
    console.log(`  1. LOP:             ${lopAddress}`);
    console.log(`  2. Fee Token:       ${feeTokenAddress}`);
    console.log(`  3. Access Token:    ${accessTokenAddress}`);
    console.log(`  4. Fee Bank Owner:  ${feeBankOwnerAddress}`);
    console.log(`  5. Rescue Delay 1:  ${rescueDelay}`);
    console.log(`  6. Rescue Delay 2:  ${rescueDelay}`);
    console.log("----------------------------------------------------");

    // Deploy the contract, passing all arguments in the correct order.
    deployer.deploy(
        EscrowFactory,
        lopAddress,
        feeTokenAddress,
        accessTokenAddress,
        feeBankOwnerAddress,
        rescueDelay,
        rescueDelay
    );
};
