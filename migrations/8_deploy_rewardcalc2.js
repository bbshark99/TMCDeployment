const TAMAGRewardCalc = artifacts.require('./TAMAGRewardCalc.sol')
const TAMAG2 = artifacts.require('./TAMAG2.sol')
const TMA = artifacts.require('./TMA.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TAMAGRewardCalc...')

  console.log('deploying from:' + deployAddress)
  // const tamag = await TAMAG.at("0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f"); // rinkeby
  // console.log("tamag",tamag.address)
  let tamag2 = await TAMAG2.at("0x927b2E769A93c07f271a17FD6aE1328ae7CB65F0");
  let tma = await TMA.at("0xb1786a290d1df9c644503a9364313782670dd803");
  let oldTamag = process.env.TAMAG

  await deployer.deploy(TAMAGRewardCalc, oldTamag, tamag2.address, tma.address, accounts[0], {
    from: deployAddress
  })
  
}
