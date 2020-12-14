
// Contracts
const TMC = artifacts.require("TMC");
const TAMAGRewardCalc = artifacts.require("TAMAGRewardCalc");
const MasterPool = artifacts.require("MasterPool");
const BigNumber = require("bignumber.js");
const IERC20 = artifacts.require("IERC20");
const ITAMAG = artifacts.require("ITAMAG");
const IUniswapV2Factory = artifacts.require("IUniswapV2Factory");
const IUniswapV2Router = artifacts.require("IUniswapV2Router02");
require('dotenv').config()
// Utils
const ether = (n) => {
  return new web3.utils.BN(
    web3.utils.toWei(n.toString(), 'ether')
  )
}
const fromEther = (n) => {
  return new BigNumber(n).dividedBy(1E18).toString();
}

const getMod256 = (n) => {
  return new web3.utils.BN(n).modulo(256);
}
const printPoolInfo = async (masterPool, _pid) => {
  let pool1 = await masterPool.getPool(_pid);
  let poo1size = await masterPool.getPoolTamagIdSize(_pid);
  console.log("lp", pool1[0]);
  console.log("allocPoint",pool1[1].toString())
  console.log("lastRewardBlock", pool1[2].toString())
  console.log("accTmcPerShare", pool1[3].toString())
  console.log("tamag", pool1[4])
  console.log("totalAmt", pool1[5].toString())
  console.log("Num tamags staked:",poo1size.toString())
}
const tick = async(tmc) => {
  console.log("tick")
  await tmc.transfer(tmc.address, 0)
}
module.exports = async function(callback) {
  try {
    // Fetch accounts from wallet - these are unlocked
    const accounts = await web3.eth.getAccounts()
    
    const tme = await IERC20.at(process.env.TME);
    const tmc = await TMC.at("0xe13559cf6eDf84bD04bf679e251f285000B9305E");
    const rewardCalc = await TAMAGRewardCalc.at("0x000a0e383aa583e759028CEeeceB07498f0aa4A0");
    const masterPool = await MasterPool.at("0x2474411A0ac484B5F8101C2E1EFbace4BdBebC8f");
    const tamag = await ITAMAG.at(process.env.TAMAG);
    let routerAdd = process.env.UNISWAP_ROUTER_ADD;

    const router = await IUniswapV2Router.at(routerAdd);

    console.log("tmc", tmc.address);
    console.log("rewardCalc", rewardCalc.address);
    console.log("masterPool", masterPool.address);
    console.log("tamag", tamag.address)

    await masterPool.unpauseDeposit();
    await masterPool.unpauseWithdraw();
    await tmc.unpause();
    callback()
    return

    // let tmcInternalBal = await tmc.balanceOf(tmc.address);
    // console.log(new BigNumber(tmcInternalBal).dividedBy(1E18).toString())
    // let pair = await tmc.uniswapV2Pair();
    // console.log("pair", pair);
    
    // get tamags
    // let numTamags = await tamag.balanceOf(accounts[0]);
    // let tamagIds = [];
    // for (let i = 0; i < numTamags; i++){
    //   let temp = await tamag.tokenOfOwnerByIndex(accounts[0],i);
    //   tamagIds.push(temp.toString());
    // }
    // console.log("tamags: ", tamagIds);
    // let tamagIds = [
    //   // '1',  '2',  '3',  '4',  '5',
    //   // '6',  '7',  '8',  '9',  '10',
    //   // '11', '29', '30', 
    //   '40', '51',
    //   '52', '53', '60', '66'
    // ]
    
    
    // await printPoolInfo(masterPool, 0);
    // await printPoolInfo(masterPool, 1);
    // await printPoolInfo(masterPool, 2);
    // let totalAlloc = await masterPool.totalAllocPoint();
    // console.log(totalAlloc)
    // callback();
    // return;

    // add to pool
    try{
      // TAMAG pool
      await masterPool.getPool(0);
    } catch {
      await masterPool.addTamagPool("45", tamag.address, true);
    }
    try{
      // TME pool
      await masterPool.getPool(1);
    } catch {
      await masterPool.add("15", tme.address, true);
    }
    try{
      // TMC pool
      await masterPool.getPool(2);
    } catch {
      await masterPool.add("15", tmc.address, true);
    }

    try{
      // TMC/TME pool
      await masterPool.getPool(3);
    } catch {
      let facAdd = process.env.UNISWAP_FACTORY_ADD;
      let fac = await IUniswapV2Factory.at(facAdd);
      let pairAdd = await fac.getPair(tmc.address, tme.address);
      console.log("pairAdd", pairAdd);
      await masterPool.add("25", pairAdd, true);
    }
    try{
      // TME/WETH pool
      await masterPool.getPool(4);
    } catch {
      let facAdd = process.env.UNISWAP_FACTORY_ADD;
      let fac = await IUniswapV2Factory.at(facAdd);
      let pairAdd = await fac.getPair(tme.address, "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");
      console.log("pairAdd", pairAdd);
      await masterPool.add("25", pairAdd, true);
    }

    await printPoolInfo(masterPool, 0);
    await printPoolInfo(masterPool, 1);
    await printPoolInfo(masterPool, 2);
    await printPoolInfo(masterPool, 3);
    await printPoolInfo(masterPool, 4);

    callback()
    return


    let toDeposit = ether(1);
    await tme.approve(masterPool.address, "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");


    let temp10 = await tme.allowance(accounts[0], masterPool.address);
    console.log(temp10.toString())
    await masterPool.deposit(1,toDeposit)

    await tamag.setApprovalForAll(masterPool.address, true);
    for (let i = 0; i < tamagIds.length; i ++){
      // check rewardcalc
      let tamagId = tamagIds[i];
      // let traits = await rewardCalc.getTamagTrait(tamagId);
      // console.log("cheer", traits[1].toString(), "energy", traits[2].toString(), "meta", traits[3].toString());
      let virtualAmt = await rewardCalc.getVirtualAmt(tamagId);
      console.log("tamag: ", tamagId, "virtual amt: " , new BigNumber(virtualAmt).dividedBy(1E18).toString());
      let deposited = await masterPool.getUserInfoTamagIdContains(0, accounts[0], tamagId);
      if (!deposited){
        console.log("Depositing", tamagId)
        await masterPool.depositTamag(0, tamagId);
      }
    }

    // let isTamagPool = await masterPool.isTamagPool(0);
    // console.log("isTamagPool", isTamagPool)
    
    // let containsTamag = await masterPool.getUserInfoTamagIdContains(0, accounts[0], tamagId)
    // console.log("containsTamag", containsTamag)
    // test deposit
    
    
    let bal = await tme.balanceOf(accounts[0])
    console.log(fromEther(bal))
    let depositAmt = await masterPool.getUserInfo(1,accounts[0]);
    depositAmt = depositAmt[0];
    if (depositAmt == 0){
      await tme.approve(masterPool.address, ether(5));
      await masterPool.deposit(1, ether(5));
    }
    // await masterPool.depositTamag(0, 2);
    // let temp = await tmc.balanceOf(accounts[0]);
    // console.log("tmc (dev): ", temp.toString());
  
    
    for (let i = 0; i < 10; i ++){
      await tick(tmc)

      let pendings = "";
      for (let i = 0; i < tamagIds.length; i ++){
        let tamagId = tamagIds[i];
        // console.log(tamagId)
        let pending = await masterPool.pendingTMCForTamag(0, accounts[0], tamagId);
        pendings = pendings + " " + fromEther(pending);

      }
      let pending2 = await masterPool.pendingTMC(1, accounts[0]);
      pendings = pendings + " " + fromEther(pending2);

      
      let temp = await tmc.balanceOf(accounts[0]);
      console.log(pendings, "| dev balance", fromEther(temp))
    }

    let temp = await tmc.balanceOf(accounts[0]);
    await masterPool.claimTamagRewards(0);
    await masterPool.deposit(1,0);
    let temp2 = await tmc.balanceOf(accounts[0]);
    let diff = new BigNumber(temp2).minus(new BigNumber(temp));
    console.log("tmc claimed: " , diff.dividedBy(1E18).toString());
    
    
    
    await printPoolInfo(masterPool, 0);
    
    // callback()
    // return;
  }
  catch(error) {
    console.log(error)
  }

  callback()
}