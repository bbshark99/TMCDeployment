const TAMAGManager = artifacts.require('./TAMAGManager.sol')
const TAMAG2 = artifacts.require('./TAMAG2.sol')
const TMA = artifacts.require('./TMA.sol')
const TAMAGRewardCalc = artifacts.require("TAMAGRewardCalc");

require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of TAMAGManager...')

  console.log('deploying from:' + deployAddress)
  // const tamag = await TAMAG.at("0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f"); // rinkeby
  // console.log("tamag",tamag.address)
  let tma = await TMA.at("0xb1786a290d1df9c644503a9364313782670dd803");
  let tamag2 = await TAMAG2.at("0x927b2E769A93c07f271a17FD6aE1328ae7CB65F0");
  let manager = await TAMAGManager.at("0xbE1b31B07B5570224903524c6E1468c3e7dc5fC0");
  let rewardcalc = await TAMAGRewardCalc.at("0x584D410466f8A1C0B18a5848FcF5a48e35D1bE62");
  await tamag2.setHatchery("0x4A5783F706782475f9EF2089D44fdf76F38e7D60")
  await tamag2.setManagerAddress(manager.address)
  await tamag2.setEquipmentContract(tma.address)

  await tma.setBonusEffect(1,5); //golden hat
  await rewardcalc.addIndiv(1);

  await tma.setBonusEffect(3,5); //ghost
  await rewardcalc.addAura(3);
  
}
