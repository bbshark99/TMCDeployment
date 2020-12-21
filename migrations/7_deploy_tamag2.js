const TAMAG2 = artifacts.require('./TAMAG2.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TAMAG2...')

  console.log('deploying from:' + deployAddress)
  // const tamag = await TAMAG.at("0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f"); // rinkeby
  // console.log("tamag",tamag.address)

  await deployer.deploy(TAMAG2, process.env.TAMA_SIGNER, accounts[0], {
    from: deployAddress
  })
  
}
