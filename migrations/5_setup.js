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
  const tmc = await TMC.at("0x3775eAd9A57185ABc20bE2bBef75625d310d479b");
  const masterPool = await MasterPool.at("0x4740D032998b4CeC04DbF49ba1bb8196b0C6eB14");
  await tmc.addMinter(masterPool.address);
  await tmc.setToWhitelistAddress(masterPool.address, true);
  await tmc.setFromWhitelistAddress(masterPool.address, true);
}
