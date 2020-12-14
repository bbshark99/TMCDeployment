const TMA = artifacts.require('./TMA.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TMA...')

  console.log('deploying from:' + deployAddress)
  // const tamag = await TAMAG.at("0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f"); // rinkeby
  // console.log("tamag",tamag.address)

  await deployer.deploy(TMA, "TAMAG Accessory NiFTygotchi", "TMA", {
    from: deployAddress
  })
  
}
