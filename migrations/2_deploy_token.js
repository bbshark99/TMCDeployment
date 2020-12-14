const TMC = artifacts.require('./TMC.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TMC...')

  console.log('deploying from:' + deployAddress)

  await deployer.deploy(TMC, {
    from: deployAddress
  })
  //TODO add minter role to masterbreeder
}
