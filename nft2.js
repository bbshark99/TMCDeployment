
// Contracts
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

    const tma = await TMA.deployed();
    const url = await tma.uri(1);
    console.log(url)
    // Hello, may i have your mainnet eth address? You have been selected for the airdrop of a golden chef hat for your continued contributions to NiFTygotchi project :)


    // let addresses = [
    //   "0x9787b0652B26A2916C561fa5256A90B04D088898", @Skockani
    //   "0x023F6a0A2311d3d7C94C67117D6be03100A56f08", @manimechian 
    //   "0xB3c6144c929652D6046c01282FA2F355D9864dB9", @Ernie812
    //   "0xB46638bF5509Fe9B81a69875AeC18aaB00160eB7", @RealCryptoBeard
    //   "0x6b0cc93fcdbe461c358ef9eca213e94537f43d44", @oinklittlepiggy
    //   "0x294400671d5AbF9396709616703a3511d41Cc6B1", @ucas
    // ]
    // mint golden chef hat
    // await tma.mint(accounts[0], 1, 1,"0x0");   

    // mint chef hat
    // await tma.mint(accounts[0], 2, 1,"0x0");   

    // mint ghost
    await tma.mint(accounts[0], 3, 1,"0x0");   

  }
  catch(error) {
    console.log(error)
  }

  callback()
}