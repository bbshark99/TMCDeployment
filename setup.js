
// Contracts
const TMC = artifacts.require("TMC");
const TAMAGRewardCalc = artifacts.require("TAMAGRewardCalc");
const MasterPool = artifacts.require("MasterPool");
const BigNumber = require("bignumber.js");
const ITAMAG = artifacts.require("ITAMAG");
const IERC20 = artifacts.require("IERC20");
const IUniswapV2Factory = artifacts.require("IUniswapV2Factory");
const IUniswapV2Router = artifacts.require("IUniswapV2Router02");
const IUnicrypt = artifacts.require("IUnicrypt");
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
  await tmc.send(0);
}
module.exports = async function(callback) {
  try {
    // Fetch accounts from wallet - these are unlocked
    const accounts = await web3.eth.getAccounts()
    const tme = await IERC20.at(process.env.TME);
    const tmc = await TMC.at("0xe13559cf6eDf84bD04bf679e251f285000B9305E");
    const rewardCalc = await TAMAGRewardCalc.deployed();
    const masterPool = await MasterPool.deployed();
    const tamag = await ITAMAG.at(process.env.TAMAG); 
    // const tamag = await ITAMAG.at("0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f"); // rinkeby
    const router = await IUniswapV2Router.at("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D");
    console.log("tmc", tmc.address);
    console.log("rewardCalc", rewardCalc.address);
    console.log("masterPool", masterPool.address);
    console.log("tamag", tamag.address)
    // let tmcBalance = await tme.balanceOf(tmc.address);
    // console.log("tmcTMEbalance", tmcBalance.toString());
    
    let amtTMC = ether(30000);
    let amtTME =  ether(30);
    let routerAdd = process.env.UNISWAP_ROUTER_ADD;
    let facAdd = process.env.UNISWAP_FACTORY_ADD;
    let tmeAdd = process.env.TME;
    let polAdd = process.env.UNICRYPT_ADD;

    let devAddTme = await tme.balanceOf(accounts[0]);
    console.log("devAddTme",devAddTme.toString());
    // let lockDuration = "60";// "63072000";
    let init = await tmc.initialized();
    console.log("init", init)
    // if (!init){
    //   await tme.transfer(tmc.address, amtTME);
    //   await tmc.initialize(amtTMC, amtTME, routerAdd, facAdd, tmeAdd);
    // }
    // callback();
    // return;
    let tmeBalance = await tme.balanceOf(tmc.address);
    console.log("tmcTMEbalance", tmeBalance.toString());
    let tmcBalance = await tmc.balanceOf(tmc.address);
    console.log("tmcTMCbalance", tmcBalance.toString());
    
    let fac = await IUniswapV2Factory.at(facAdd);
    let pairAdd = await fac.getPair(tmc.address, tme.address);
    console.log("pairAdd", pairAdd);

    let pair = await IERC20.at(pairAdd);
    let lpBalance = await pair.balanceOf(tmc.address);
    console.log("lpBalance", lpBalance.toString())

    let devLPBalance = await pair.balanceOf(accounts[0]);
    console.log("DEV lpBalance", devLPBalance.toString())
    try{
        console.log("locking");
        const now = Math.floor(Date.now()/1000);
        let lockDuration = 3600*24*365*2;//2yrs
        await pair.approve(polAdd, devLPBalance);
        let pol = await IUnicrypt.at(polAdd);
        await pol.depositToken(pair.address, devLPBalance,now+lockDuration)
        let polTest = await pol.getUserVestingAtIndex(pair.address, accounts[0],0);
        console.log(polTest[0].toString(), polTest[1].toString())
    }catch {}
      
    // await tmc.claimLiquidity(polAdd, pairAdd);
    // lpBalance = await pair.balanceOf(accounts[0]);
    // console.log("owner lpBalance", lpBalance.toString())

    // make eth/tmc pool
  //   let tmcEthPairAdd = await fac.getPair(tmc.address, "0xc778417E063141139Fce010982780140Aa0cD5Ab");
  //   console.log("tmcEthPairAdd",tmcEthPairAdd);
  //   if (tmcEthPairAdd == "0x0000000000000000000000000000000000000000"){
  //     await fac.createPair(tmc.address, "0xc778417E063141139Fce010982780140Aa0cD5Ab");
  //     tmcEthPairAdd = await fac.getPair(tmc.address, "0xc778417E063141139Fce010982780140Aa0cD5Ab");
  // }
  //   console.log("tmcEthPairAdd",tmcEthPairAdd);
  
  // await tmc.setUniswapV2Pair(tmcEthPairAdd);
  // await tmc.setToWhitelistAddress(tmcEthPairAdd,true);
  // await tmc.setFromWhitelistAddress(tmcEthPairAdd,true);
  
    await tmc.setUniswapV2Router(router.address);
    callback();
    return;
    
    // add liquid
    // const now = Math.floor(Date.now()/1000);
    let devTmcBal = await tmc.balanceOf(accounts[0]);
    console.log("devTmcBal", fromEther(devTmcBal));
    await tmc.approve(router.address, ether(5000))
    await router.addLiquidityETH(tmc.address, ether(5000),0,0,accounts[0],now + 180,{value: ether(5)})
    console.log(
      "added liquidity"
    )
    let tmcEth = await IERC20.at(tmcEthPairAdd);
    let tmcEthLpBal = await tmcEth.balanceOf(accounts[0]);
    console.log("tmcEthLpBal",fromEther(tmcEthLpBal));
    callback();
    return;
    
    // get tamags
    // let numTamags = await tamag.balanceOf(accounts[0]);
    // let tamagIds = [];
    // for (let i = 0; i < numTamags; i++){
    //   let temp = await tamag.tokenOfOwnerByIndex(accounts[0],i);
    //   tamagIds.push(temp.toString());
    // }
    // console.log("tamags: ", tamagIds);
    let tamagIds = [
      '1',  '2',  '3',  '4',  '5',
      '6',  '7',  '8',  '9',  '10',
      '11', '29', '30', '40', '51',
      '52', '53', '60', '66'
    ]
    
    // await tamag.setApprovalForAll(masterPool.address, true);
    // check rewardcalc
    let tamagId = 2;
    // let traits = await rewardCalc.getTamagTrait(tamagId);
    // console.log("cheer", traits[1].toString(), "energy", traits[2].toString(), "meta", traits[3].toString());
    let virtualAmt = await rewardCalc.getVirtualAmt(tamagId);
    console.log("tamag: ", tamagId, "virtual amt: " , new BigNumber(virtualAmt).dividedBy(1E18).toString());
    
    // callback();
    // return;

    // add to pool
    await masterPool.addTamagPool("100", "0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f", true);
    await printPoolInfo(masterPool, 0);
    
    // test deposit
    await masterPool.depositTamag(0, 1);
    
    await tick()

    // await masterPool.depositTamag(0, 2);
    let temp = await tmc.balanceOf(accounts[0]);
    console.log("tmc (dev): ", temp.toString());

    await masterPool.claimTamagRewards(0);

    temp = await tmc.balanceOf(accounts[0]);
    console.log("tmc (dev): ", temp.toString());


    await printPoolInfo(masterPool, 0);

  }
  catch(error) {
    console.log(error)
  }

  callback()
}