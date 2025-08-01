module.exports = {
  networks: {
    tron: {
      // Don't put your private key here:
      privateKey: process.env.PRIVATE_KEY_MAINNET,
      /**
       * Create a .env file (it must be gitignored) containing something like
       *   export PRIVATE_KEY_MAINNET=4E7FEC...656243
       * Then, run the migration with:
       *   source .env && tronbox migrate --network mainnet
       */
      userFeePercentage: 100,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://api.trongrid.io',
      network_id: '1'
    },
    shasta: {
      privateKey: process.env.PRIVATE_KEY_SHASTA,
      userFeePercentage: 50,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://api.shasta.trongrid.io',
      network_id: '2'
    },
    nile: {
      privateKey: process.env.PRIVATE_KEY_NILE,
      userFeePercentage: 100,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://nile.trongrid.io',
      network_id: '3'
    }
  },
  compilers: {
    solc: {
      version: '0.8.23',
      // An object with the same schema as the settings entry in the Input JSON.
      // See https://docs.soliditylang.org/en/latest/using-the-compiler.html#input-description
      settings: {
        optimizer: {
          enabled: true,
          runs: 1000000
        },
        evmVersion: 'shanghai',
        viaIR: true,
      }
    }
  }
};
