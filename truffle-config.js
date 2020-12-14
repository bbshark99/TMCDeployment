// const path = require("path");
const HDWalletProvider = require('@truffle/hdwallet-provider')
require('dotenv').config()  // Store environment-specific variable from '.env' to process.env
MAINNET_KEY = process.env.MAINNET_KEY //tamadeployertest
INFURA_API_KEY = process.env.INFURA_API_KEY

const web3 = require('web3')
var BN = web3.utils.BN

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      // gas: 20000000,
      network_id: '*',
      skipDryRun: true
    },
    'mainnet-fork': {
      provider: () =>
        new HDWalletProvider(MAINNET_KEY, 'http://localhost:8545'),
      network_id: '*',
      skipDryRun: true,
      gas: 10000000,
      networkCheckTimeout: 30000,
      gasPrice: web3.utils.toWei('50', 'gwei') // 100 gwei
    },
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          MAINNET_KEY,
          `https://rinkeby.infura.io/v3/` + INFURA_API_KEY
        ),
        skipDryRun: true,
      network_id: 4,
      gas: 6800000, // Gas limit used for deploys
      gasPrice: web3.utils.toWei('100', 'gwei') // 100 gwei
    },

    ropsten: {
      provider: () =>
        new HDWalletProvider(
          MAINNET_KEY,
          `https://ropsten.infura.io/v3/` + INFURA_API_KEY
        ),
        skipDryRun: true,
      network_id: 3, // Ropsten's id
      gasPrice: web3.utils.toWei('50', 'gwei'), // 100 gwei
      gas: 4465030 // Ropsten has a lower block limit than mainnet
    },
   


   
    mainnet: {
      provider: () =>
        new HDWalletProvider(
          MAINNET_KEY,
          // 'http://localhost:6666'
          'https://mainnet.infura.io/v3/' + INFURA_API_KEY
        ),
      network_id: 1,
      gas: 10000000,
      skipDryRun: true,
      gasPrice: String(web3.utils.toWei('55', 'gwei'))
    }
  },
  compilers: {
    solc: {
      version: '^0.6.0'
    }
  }
}
