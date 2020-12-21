const TAMAGManager = artifacts.require('./TAMAGManager.sol')
const TAMAG2 = artifacts.require('./TAMAG2.sol')

require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TAMAGManager...')

  console.log('deploying from:' + deployAddress)
  // const tamag = await TAMAG.at("0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f"); // rinkeby
  // console.log("tamag",tamag.address)
  let tamag2 = await TAMAG2.at("0x927b2E769A93c07f271a17FD6aE1328ae7CB65F0");
  let tamag1 = process.env.TAMAG;
  let chi = "0x0000000000004946c0e9F43F4Dee607b0eF1fA1c";
  await deployer.deploy(TAMAGManager, process.env.TAMA_SIGNER, accounts[0], tamag1, tamag2.address, chi,{
    from: deployAddress
  })
  
}
