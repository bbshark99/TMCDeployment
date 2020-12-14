const MasterPool = artifacts.require('./MasterPool.sol')
const TMC = artifacts.require('./TMC.sol')
require('dotenv').config()


const ether = (n) => {
  return new web3.utils.BN(
    web3.utils.toWei(n.toString(), 'ether')
  )
}

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  const tmc = await TMC.at("0xe13559cf6eDf84bD04bf679e251f285000B9305E");
  const masterPool = await MasterPool.deployed();
  await tmc.addMinter(masterPool.address);
  await tmc.setToWhitelistAddress(masterPool.address, true);
  await tmc.setFromWhitelistAddress(masterPool.address, true);
}
