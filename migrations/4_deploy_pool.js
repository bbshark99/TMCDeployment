const MasterPool = artifacts.require('./MasterPool.sol')
const TAMAGRewardCalc = artifacts.require('./TAMAGRewardCalc.sol')
const TMC = artifacts.require('./TMC.sol')
require('dotenv').config()

module.exports = async (deployer, network, accounts) => {
  console.log(accounts)
  let deployAddress = accounts[0] // by convention
  console.log('Preparing for deployment of MasterPool...')
  let block = await web3.eth.getBlock("latest")
  console.log('blocknumber',block.number)

  console.log('deploying from:' + deployAddress)
  const tmc = await TMC.at("0x3775eAd9A57185ABc20bE2bBef75625d310d479b");
  const tamagRewardCalc = await TAMAGRewardCalc.at("0x670B2cAc04011AabdA130Be652269e6C9266A2Ae");

  // let tmcPerBlock = "40000000000000000000";
  // let startBlock = block.number;
  // let bonusEndBlock = block.number + 10;


  console.log(block.number);
  const now = Math.floor(Date.now()/1000);
  const target = 1607785200 - 600; // 5min buffer for block drift 
  let targetBlock = block.number + Math.floor((target-now)/15);
  console.log("targetBlock", targetBlock)
  let tmcAdd = tmc.address;
  let devAdd = "0xC2884De64ceFF15211Bb884a1E84F5aeaD9fdc7c"
  let tmcPerBlock = "40000000000000000000"
  let startBlock = block.number
  let bonusEndBlock = block.number
  let rewardCalcAdd = tamagRewardCalc.address;

  console.log(tmcAdd, devAdd, tmcPerBlock, startBlock, bonusEndBlock, rewardCalcAdd);
  await deployer.deploy(MasterPool, tmcAdd, accounts[0], tmcPerBlock, startBlock, bonusEndBlock, rewardCalcAdd, accounts[0], {
    from: deployAddress
  })

}
