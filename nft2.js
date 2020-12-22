
// Contracts
const TMA = artifacts.require("TMA");
const TMADispense = artifacts.require("TMADispense");
const MasterPool = artifacts.require("MasterPool");
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
    // const pool = await MasterPool.at("0x2474411A0ac484B5F8101C2E1EFbace4BdBebC8f");
    const tma = await TMA.at(process.env.TMA);
    const dispense = await TMADispense.at(process.env.TMADISPENSE)
    // await tma.mint(accounts[0],1,7,"0x0"); // 7 golden chef hats
    // await tma.mint(accounts[0],2,31,"0x0"); // 31 chef hats
    // await tma.mint(accounts[0],3,4,"0x0"); // 4 ghosts
    // let test = await tma.setURI("ipfs://ipfs/QmQn4BTG8WqMoUwZFwyEpyC9cyKEFj4KYxHm1ks8n829PC/{id}.json");
    
    // let test = await dispense.createSales(4, true, 1, 0);
    // test = await dispense.createSales(5, true, 1, 0);
    // test = await dispense.createSales(6, true, 1, 0);

    // let a = await tma.balanceOf(dispense.address, 4);
    // let b = await tma.balanceOf(dispense.address, 5);
    // let c = await tma.balanceOf(dispense.address, 6);
    // console.log(a.toString(),b.toString(),c.toString())
    // console.log(dispense.address)
    // let test = await tma.safeTransferFrom(accounts[0], dispense.address, 4, 100, "0x0")
    // let test = await dispense.createSales(4, true, 1, 0);
    // test = await dispense.createSales(5, true, 1, 0);
    // test = await dispense.createSales(6, true, 1, 0);
    // let test = await tma.uri(1);
    // console.log(test);
    // let a = await tma.mintBatch(dispense.address, [4,5,6],[100,100,100], "0x0")
    // console.log(a);


    await tma.setBonusEffect(4,1);
    await tma.setBonusEffect(5,1);
    await tma.setBonusEffect(6,1);
    await rewardCalc.addIndiv(4);
    await rewardCalc.addIndiv(5);
    await rewardCalc.addIndiv(6);
    // let b1 = await tma.balanceOf(accounts[0],1);
    // console.log(b1.toString())
    callback()
    return;
    const url = await tma.uri(1);
    // airdrop for white chef hat, find DepositTamag events
    // let whitechefhatusers = new Set();
    // let events = await pool.getPastEvents("DepositTamag", { fromBlock: 0, toBlock: 11452096 });
    // for (let e of events){
    //   if (e.returnValues && e.returnValues._pid == '0'){
    //     // console.log(e.returnValues.user, e.returnValues.tamagId);
    //     whitechefhatusers.add(e.returnValues.user);
    //   }
    // }
    // console.log(whitechefhatusers)
    await tma.mint(accounts[0],2,1,"0x0"); // 31 chef hats

    let whitechefhatusers = ['0xB46638bF5509Fe9B81a69875AeC18aaB00160eB7',
    '0x12429F85Fa35183Bc7cA6750303ee3f6AFE31d13',
    '0x6CF51FDeF74d02296017A1129086Ee9C3477DC01',
    '0x46B8FfC41F26cd896E033942cAF999b78d10c277',
    '0xe8c8eAB7617f6EE168577498562C7cEFF762113d',
    // '0xC2884De64ceFF15211Bb884a1E84F5aeaD9fdc7c',
    '0xc05bc25EAa52a23476E113b9A139a66e7473b364',
    '0xeA5DcA8cAc9c12Df3AB5908A106c15ff024CB44F',
    '0x294400671d5AbF9396709616703a3511d41Cc6B1',
    '0x9787b0652B26A2916C561fa5256A90B04D088898',
    '0x1DF610D171D899b63Ff10005Ecaa5da780f0eE1D',
    '0x44C767F3513132071cecA2AA05Bd4e2152d81dAc',
    '0x1E18b8B6F27568023E0b577CBEE1889391B2F444',
    '0x8A71A81F119d85F0750C50d3abF724817B8C7B6B',
    '0xF9891097983c22e31fCE739EDefADAc94927507c',
    '0x7ab417afd459335213601F160DDA165b789B0193',
    '0x414533F66a8359dB22C3b74733826FdFe7Fcc72f',
    '0xf601b1c1Dce139469E4969938c1ce9D58e30bdB9',
    '0x5B6B890AaBa48C6F954B655Eafd8f30428CE633a',
    '0x9af2De893816C024D1de91Cd5c0b04808FE980aE',
    '0x4d28975B4Ed2a1a9A00C657f28344DCe37EE0Ac6',
    '0x032dA9D10962499Bf8694596d747cb85503eccf8',
    '0x5984bb82F11171cb1DC2287E2A6935c44D491538',
    '0xb9c37ed113879E85c83D5338fF40f5009b2EC271',
    '0x0a3eECc99a1d5f8FAF89F566A7aa9cd025AE895f',
    '0x6b0CC93FCdBE461c358eF9ecA213E94537f43d44',
    '0xC065A07F9FE675D3a4B452A791e187bb4CEfAa43',
    '0xD3aBD40212649e9B100Df7b26F6792eD91034a56',
    '0xD77A4103B51325a2A0526275AA067E1605e67441',
    '0x4C632B5B896245963B4Ca5C625463BE7CcD683fa',
    '0xd9854F3ab29A69c89Cc57fb675C48Ecd69b61Aec',
    '0xc82a75D564521306e7Ee9eBD530a459292c45Ae7'
  ]
  
  for (let a of whitechefhatusers){
      console.log("sending white: ", a)
      await tma.safeTransferFrom(accounts[0], a, 2, 1, "0x0");
    }
  console.log(whitechefhatusers.length);

  let goldenchefhatusers = [
    "0x9787b0652B26A2916C561fa5256A90B04D088898", // @Skockani
    "0x023F6a0A2311d3d7C94C67117D6be03100A56f08", // @manimechian 
    "0xB3c6144c929652D6046c01282FA2F355D9864dB9", // @Ernie812
    "0xB46638bF5509Fe9B81a69875AeC18aaB00160eB7", // @RealCryptoBeard
    "0x6b0cc93fcdbe461c358ef9eca213e94537f43d44", // @oinklittlepiggy
    "0x294400671d5AbF9396709616703a3511d41Cc6B1", // @ucas
    "0xD3aBD40212649e9B100Df7b26F6792eD91034a56", // code reader
  ]
  // console.log(goldenchefhatusers.length);
  // for (let a of goldenchefhatusers){
  //   console.log("sending golden: ", a)
  //   await tma.safeTransferFrom(accounts[0], a, 1, 1, "0x0");
  // }

  let ghostusers = [
    '0x4d28975B4Ed2a1a9A00C657f28344DCe37EE0Ac6',
    '0xC63168e42AbE2C7dBBCf58D17f1445248F669B39',
    '0x05c09bBf110750C64BFBeA847147B423743c4AC6',
    '0x05c09bBf110750C64BFBeA847147B423743c4AC6'
  ]
  // await tma.safeTransferFrom(accounts[0], "0x4d28975B4Ed2a1a9A00C657f28344DCe37EE0Ac6", 3, 1, "0x0");
  // await tma.safeTransferFrom(accounts[0], "0xC63168e42AbE2C7dBBCf58D17f1445248F669B39", 3, 1, "0x0");
  // await tma.safeTransferFrom(accounts[0], "0x05c09bBf110750C64BFBeA847147B423743c4AC6", 3, 2, "0x0");
  // console.log(ghostuser)
    
    // Hello, may i have your mainnet eth address? You have been selected for the airdrop of a golden chef hat for your continued contributions to NiFTygotchi project :)

    
    // mint golden chef hat
    // await tma.mint(accounts[0], 1, 1,"0x0");   

    // mint chef hat
    // await tma.mint(accounts[0], 2, 1,"0x0");   

    // mint ghost
    // await tma.mint(accounts[0], 3, 1,"0x0");   

  }
  catch(error) {
    console.log(error)
  }

  callback()
}