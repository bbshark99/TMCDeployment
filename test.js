
// Contracts
const TMC = artifacts.require("TMC");
const TAMAGRewardCalc = artifacts.require("TAMAGRewardCalc");
const MasterPool = artifacts.require("MasterPool");
const BigNumber = require("bignumber.js");
const ITAMAG = artifacts.require("ITAMAG");
const IERC20 = artifacts.require("IERC20");
const IUniswapV2Factory = artifacts.require("IUniswapV2Factory");
const IUnicrypt = artifacts.require("IUnicrypt");
// Utils
const ether = (n) => {
  return new web3.utils.BN(
    web3.utils.toWei(n.toString(), 'ether')
  )
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
    const tme = await IERC20.at("0x6E742E29395Cf5736c358538f0f1372AB3dFE731");
    const tmc = await TMC.deployed();
    const rewardCalc = await TAMAGRewardCalc.deployed();
    const masterPool = await MasterPool.deployed();
    const tamag = await ITAMAG.at("0xa6D82Fc1f99A868EaaB5c935fe7ba9c9e962040E"); //mainnet
    // const tamag = await ITAMAG.at("0x2474411a0ac484b5f8101c2e1efbace4bdbebc8f"); // rinkeby

    console.log("tmc", tmc.address);
    console.log("rewardCalc", rewardCalc.address);
    console.log("masterPool", masterPool.address);
    console.log("tamag", tamag.address)
    // let tmcBalance = await tme.balanceOf(tmc.address);
    // console.log("tmcTMEbalance", tmcBalance.toString());
    
    let amtTMC = ether(10000);
    let amtTME =  ether(5);
    let routerAdd = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    let facAdd = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
    let tmeAdd = "0x6E742E29395Cf5736c358538f0f1372AB3dFE731";
    let polAdd = "0x17e00383A843A9922bCA3B280C0ADE9f8BA48449";
    let lockDuration = "60";// "63072000";
    let init = await tmc.initialized();
    if (!init){
      await tme.transfer(tmc.address, amtTME)
      await tmc.initialize(amtTMC, amtTME, routerAdd, facAdd, tmeAdd, polAdd, lockDuration);
    }
    
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

    
    let pol = await IUnicrypt.at(polAdd);
    let polTest = await pol.getUserVestingAtIndex(pairAdd, tmc.address,0);
    console.log(polTest[0].toString(), polTest[1].toString())


    // await tmc.claimLiquidity(polAdd, pairAdd);
    // lpBalance = await pair.balanceOf(accounts[0]);
    // console.log("owner lpBalance", lpBalance.toString())

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