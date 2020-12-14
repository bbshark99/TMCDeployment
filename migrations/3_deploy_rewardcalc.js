const TAMAGRewardCalc = artifacts.require('./TAMAGRewardCalc.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TAMAGRewardCalc...')

  console.log('deploying from:' + deployAddress)
  // const tamag = await TAMAG.at("0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f"); // rinkeby
  // console.log("tamag",tamag.address)

  let tamagAdd = process.env.TAMAG;
  await deployer.deploy(TAMAGRewardCalc, tamagAdd, {
    from: deployAddress
  })
}
