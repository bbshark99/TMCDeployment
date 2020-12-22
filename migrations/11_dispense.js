const TMADispense = artifacts.require('./TMADispense.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TMADispense...')

  console.log('deploying from:' + deployAddress)
  // const tamag = await TAMAG.at("0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f"); // rinkeby
  // console.log("tamag",tamag.address)

  let chi = "0x0000000000004946c0e9F43F4Dee607b0eF1fA1c";
  await deployer.deploy(TMADispense, accounts[0], process.env.TMA, process.env.TMC, chi, {
    from: deployAddress
  })

  const dispense = await TMADispense.deployed();
  let test = await dispense.createSales(4, true, 1, 0);
  test = await dispense.createSales(5, true, 1, 0);
  test = await dispense.createSales(6, true, 1, 0);


}
