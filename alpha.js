
// Contracts
const TMC = artifacts.require("TMC");
const TAMAGRewardCalc = artifacts.require("TAMAGRewardCalc");
const MasterPool = artifacts.require("MasterPool");
const BigNumber = require("bignumber.js");
const IERC20 = artifacts.require("IERC20");
const ITAMAG = artifacts.require("ITAMAG");
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
    const tmc = await TMC.at("0x4a116458E0FBD5E5F7C2D024C46AAbeA7925d1ee");
    // const tmc = await TMC.deployed();
    const rewardCalc = await TAMAGRewardCalc.deployed();
    const masterPool = await MasterPool.deployed();
    const tamag = await ITAMAG.at(process.env.TAMAG);
    const router = await IUniswapV2Router.at("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D");

    console.log("tmc", tmc.address);
    console.log("rewardCalc", rewardCalc.address);
    console.log("masterPool", masterPool.address);
    console.log("tamag", tamag.address)


    let tmcInternalBal = await tmc.balanceOf(tmc.address);
    console.log(new BigNumber(tmcInternalBal).dividedBy(1E18).toString())
    let pair = await tmc.uniswapV2Pair();
    console.log("pair", pair);

    // await tmc.setUniswapV2Pair("0xeec9672e7a7a6ffd88c0c18f438840c9578b5e63")
    // let unipair = await IERC20.at("0xeec9672e7a7a6ffd88c0c18f438840c9578b5e63");
    // let bala = await unipair.balanceOf(accounts[0]);
    // console.log(bala.toString());

    // await unipair.transfer("0x0000000000000000000000000000000000000000", "1638902540129624625")
    
    // bala = await unipair.balanceOf(accounts[0]);
    // console.log(bala.toString());
    // await unipair.transfer("0", 
    
    let a = await tmc.devDivisor();
    let b = await tmc.poolDivisor();
    let c = await tmc.lpRewardDivisor();
    console.log(a.toString(),b.toString(),c.toString());
    // await tmc.setDevDivisor(4);
    // await tmc.setPoolDivisor(4);
    // await tmc.setLpRewardDivisor(4);
    // await tmc.lockLiquidity(ether(100));
    // await tmc.swapTokensForEth(ether(50));
    // const now = Math.floor(Date.now()/1000);

    // let weth = await router.WETH();
    // console.log("weth", weth);
    // let myBal = await tmc.balanceOf(accounts[0]);
    // console.log("myBal", myBal.toString())
    // await tmc.approve(router.address, ether(50))
    
    // await router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    //   ether(50),
    //   0,
    //   [tmc.address, weth],
    //   accounts[0],
    //   now + 120
    // );
    // console.log("swapped")
    
    tmcInternalBal = await tmc.balanceOf(tmc.address);
    console.log(new BigNumber(tmcInternalBal).dividedBy(1E18).toString())
    // callback()
    // return
    
    callback()
    return
    
    
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
      await masterPool.getPool(0);
    } catch {
      await masterPool.addTamagPool("400", tamag.address, true);
    }
    try{
      await masterPool.getPool(1);
    } catch {
      await masterPool.add("100", tme.address, true);
    }
    try{
      await masterPool.getPool(2);
    } catch {
      await masterPool.add("100", "0xf65fe53cd2ae4c939bd92222bc7aa84eb961f8ff", true);
    }

    try{
      await masterPool.getPool(3);
    } catch {
      await masterPool.add("100", "0x5CbE88fBd6D720c906a3f68295b49daA170ee64F", true);
    }

    await printPoolInfo(masterPool, 3);
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