
// Contracts
const TAMAG2 = artifacts.require("TAMAG2");
const OldTAMAG = artifacts.require("OldTAMAG");
const TAMAGManager = artifacts.require("TAMAGManager");
const TAMAGRewardCalc = artifacts.require("TAMAGRewardCalc");
const MasterPool = artifacts.require("MasterPool");
const TMA = artifacts.require("TMA");
const axios = require("axios");
// const TMEHatchery = artifacts.require("TMEHatchery");
// const TMETraitOracle2 = artifacts.require("TMETraitOracle2");
// Utils
const ether = (n) => {
  return new web3.utils.BN(
    web3.utils.toWei(n.toString(), 'ether')
  )
}

module.exports = async function(callback) {
  try {
    // Fetch accounts from wallet - these are unlocked
    const accounts = await web3.eth.getAccounts()
    const manager = await TAMAGManager.deployed(process.env.MANAGER);
    const tamag2 = await TAMAG2.at(process.env.TAMAG2);
    const tma = await TMA.at(process.env.TMA);
    const rewardcalc = await TAMAGRewardCalc.at(process.env.REWARDCALC2);
    const pool = await MasterPool.at(process.env.POOL);

    // await rewardcalc.setTma(tma.address);
    // await tamag2.setEquipmentContract(tma.address);

    // await rewardcalc.setTamag(tamag2.address);
    // await manager.setNewTamagContract(tamag2.address);
    
    // await tamag2.setHatchery(process.env.HATCHERY)
    // await tamag2.setManagerAddress(manager.address)
    // await tamag2.setEquipmentContract(tma.address)
    // // await tamag2.setTokenId(100); <-- ??????????????

    // let a = await tma.mint(accounts[0], 2, 1, "0x0");
    // await rewardcalc.removeAura(3);
    // await rewardcalc.addIndiv(3);
    // await rewardcalc.addIndiv(1);
    let test2 = await tma.setURI("ipfs://ipfs/QmZmpH9gTMmEkFBvThNBg2bMqFEWK1T7vQP1jRLuYGsi62/{id}.json");
    // console.log(test2)
    // tma change - update rewardcalc, tamag2, manager
    // await rewardcalc.setTma(tma.address);
    // await tamag2.setEquipmentContract(tma.address);
    // let hat = await tma.setBonusEffect(1,5);
    // hat = await tma.setBonusEffect(3,5);
    // await pool.setTamagRewardCalc(rewardcalc.address);
    console.log(test2)
    callback()
    return;

    // on hatchery side:
    // await hatchery.pauseHatching();
    // await hatchery.setTAMAG("0xA0244AfBC4d0366eEBbd4cBfcF82CE49547D8eaa");
    await tamag2.setTokenId(100);
    await tamag2.unpause();
    // await hatchery.unpauseHatching();
    
    // on masterpool
    // await pool.pauseDeposit()
    // await pool.pauseWithdraw()
    // await pool.setTamagRewardCalc(rewardcalc.address);
    // await pool.set(0,0,true);
    // await pool.addTamagPool("45", tamag2.address, true);
    // await pool.unpauseDeposit()
    // await pool.unpauseWithdraw()

    let poolLength = await pool.poolLength();
    console.log("poolLength", poolLength.toString())



    // let t1 = await tamag2.tokenURI(101);
    // console.log(t1)
    // let t2 = await rewardcalc.getBonuses(101);
    // console.log(t2.toString());
    // let a = await tma.mint(accounts[0], 1, 1, "0x0");
    // let test1 = await tamag2.getEquipAtSlot(101, 2);
    // let test2 = await tamag2.getEquippedSlot(101, 3);
    // let test3 = await tamag2.isEquipped(101, 3);
    // let test1 = await tma.bonusEffect(3);
    // let test1 = await rewardcalc.addIndiv(3);
    // let test2 = await tma.setURI("https://us-central1-nfgotchi-test.cloudfunctions.net/widgets/resource/tma/{id}");
    // let test3 = await rewardcalc.removeAura(3);
    // let test1 = await manager.setNewTamagContract("0xBD2Ff44563e1fBF72D28F07E3D3C68AF3eaAB27e");
    // test = await rewardcalc.removeAura(3);
    // console.log( test2)
    callback()
    return;
    // const pool = await MasterPool.at("0x2474411A0ac484B5F8101C2E1EFbace4BdBebC8f");
    // console.log(tamag2.address)
    // console.log(rewardcalc.address)
    // let g = await pool.setTamagRewardCalc(rewardcalc.address)
    // console.log(g);
    // let uri = await tamag2.manager();
    // let b = await rewardcalc.ownerToAuraAmt(accounts[0])
    // console.log(b.toString())
    // setup for indiveffect
    // let test = await rewardcalc.addIndiv(1);
    // let a = await rewardcalc.getVirtualAmt(1);
    let a1 = await tamag2.isEquipped(57,1);
    let a2 = await tamag2.getEquipAtSlot(57,1);
    let a3 = await tamag2.getEquippedSlot(1,1);
    let b2 = await rewardcalc.getBonuses(57);
    console.log(a1, b2.toString(), a2.toString(), a3.toString());
    // let a1 = await rewardcalc.oldTamag();
    // let a2 = await rewardcalc.setTamag(tamag2.address);
    // let a3 = await rewardcalc.tma();
    // console.log( a1,a2,a3)
    // let t1 = await rewardcalc.setTamag(tamag2.address);
    // let t2 = await manager.setNewTamagContract(tamag2.address);
    // console.log(t1, t2)


    // await rewardcalc.setTamag(tamag2.address);
    // await manager.setNewTamagContract(tamag2.address);

    // const pool = await MasterPool.at("0x4c10eB424cC0a86D8DE211030c585971123C1dBf");
    // const d = await pool.setTmc("0x3775eAd9A57185ABc20bE2bBef75625d310d479b")
    // console.log(d)
    // console.log(d[0].toString(), d[1].toString(), d[4].toString())
    // const c = await pool.poolLength();
    // console.log(c.toString())
    // let a = await pool.set(4,0,false);
    // console.log(tamag2.address)

    // let t1 = await rewardcalc.oldTamag();
    // let t2 = await rewardcalc.newTamag();
    // console.log(t1,t2)
    // let bonus = await rewardcalc.getBonuses(1);
    // console.log(bonus.toString())
    // let u = await pool.getUserInfo(2, accounts[0])
    // console.log(u[0].toString(), u[1].toString())

    let b1 = await tma.bonusEffect(57);
    console.log(b1.toString())
    // let equipped = await tamag2.isEquipped(1,1);
    // console.log(equipped.toString())
    let test = await rewardcalc.addIndiv(3);
    test = await rewardcalc.removeAura(3);
    // console.log(test)
    let c1 = await rewardcalc.isIndivEffect(1);
    console.log(c1.toString());
    // // let exists = await tamag2.exists(1);
    // // console.log("exists", exists)
    // let a = await rewardcalc.getVirtualAmt(1);
    // console.log(a.toString())



    // let b = await tamag2.traits(1);
    // let cheer = await rewardcalc.getCheerfulness(b);
    // let energy = await rewardcalc.getEnergy(b);
    // let meta = await rewardcalc.getMetabolism(b);
    // console.log(cheer.toString(), energy.toString(), meta.toString())

    // let hat = await tma.setBonusEffect(1,5);
    // console.log(hat)
    // console.log("done")
    // let b = await pool.addTamagPool("45", "0x3F09Ff43c5a8aa83781527690A4090AF821ae45b", true);

    // let a = await tamag2.unpause();
    // let a = await tma.mint(accounts[0], 1, 1, "0x0");
    // let b = await tma.mint(accounts[0], 2, 1, "0x0");
    // let c = await tma.mint(accounts[0], 3, 1, "0x0");
    // console.log(c);
    // console.log(a,b);



    // let u = await pool.getUserInfo(0, accounts[0]);
    // console.log(u[0].toString());
    callback()
    return;
    // let a = await tamag2.setEquipmentContract("0x82A0685D11945f946f9b8696157a22015d9a804f")
    // let a = await tma.setURI("https://us-central1-nfgotchi-test.cloudfunctions.net/widgets/resource/tma/{id}")
    // await pool.withdrawTamag(4, 2);
    // await pool.set(4,0,true);
    // await pool.addTamagPool("45", "0xc55A1d92c90680978e54d0a2AEb855FDa94D620b", true);
    // let events = await pool.getPastEvents("DepositTamag", { fromBlock: 0, toBlock: 'latest' });
    // for (let e of events){
    //   if (e.returnValues && e.returnValues._pid == '4'){
    //     // console.log(e.returnValues.user, e.returnValues.tamagId);
    //     console.log("Depsoit", e.returnValues.tamagId)
    //   }
    // }
    // let events2 = await pool.getPastEvents("WithdrawTamag", { fromBlock: 0, toBlock: 'latest' });
    // for (let e of events2){
    //   if (e.returnValues && e.returnValues._pid == '4'){
    //     // console.log(e.returnValues.user, e.returnValues.tamagId);
    //     console.log("Withdraw", e.returnValues.tamagId)
    //   }
    // }
    // let maxIdInTamag1 = 83;
    await hatchery.pauseHatching();
    await pool.pauseDeposit()

    await tamag2.setTokenId(maxIdInTamag1);
    await hatchery.setTAMAG(tamag2.address);
    await tamag2.unpause();

    await pool.setTamagRewardCalc(rewardcalc.address);
    await pool.set(0,0,true);
    await pool.addTamagPool("45", tamag2.address, true);
    await pool.unpauseDeposit()


    // await pool.set
    // make everyone withdraw their tamags.
    // all tamags must withdraw
    // STEPS
    // 1. pause hatchery hatching function
    // 2. find max id in old tamag contract, set to new tamag contract
    // 3. set hatchery tamag address to new tamag addres
    // 4. unpause hatchery
    // 5. add tamagv2 pool in masterpool, alloc of old pool to 0
    // 6. switch masterpool rewardcalc to new rewardcalc

    // let oldTamagAdd = await manager.oldTamag();
    // let newTamagAdd = await manager.newTamag();
    // console.log(oldTamagAdd, newTamagAdd)
    // let oldTamag = await OldTAMAG.at("0x06C7186e6A71719C427D52E625801A0068c72bCD");

    // let olduri = await oldTamag.tokenURI(2);
    // console.log(olduri)
    // let traits = await tamag.traits(1);
    // console.log(traits.toString())
    // let tokenuri = await tamag.tokenURI(1);
    // console.log(tokenuri)

  }
  catch(error) {
    console.log(error)
  }

  callback()
}