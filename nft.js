
// Contracts
const ITAMAG = artifacts.require("ITAMAG");
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

    const tamag = await ITAMAG.at("0xa6D82Fc1f99A868EaaB5c935fe7ba9c9e962040E");
    // const hatchery = await TMEHatchery.deployed();
    // const oracle = await TMETraitOracle2.deployed();
    const OG1 = []
    const OG2 = []

    console.log("tamag", tamag.address);
    // console.log("hatchery", hatchery.address);
    // console.log("oracle", oracle.address);
    // try change NFT meta
    let p = [];

    for (let i = 1; i < 70; i ++){
      p.push(tamag.tokenURI(i).then((uri) => {
        uri = uri.replace("ipfs://ipfs","https://ipfs.io/ipfs");
        return axios.get(uri).then((r) => {
          let data = r.data.attributes;
        // console.log(data)
          for (let a of data){
            if (a.trait_type == "Special"){
              let s = a.value;
              return s
            }
          }
        })
      }));
    }
    await Promise.all(p).then((results) => {
      console.log(results)
      for (let i = 0; i < results.length; i++){
        let a = results[i];
        if (a=="OG1"){
          OG1.push(i+1);
        }else if (a=="OG2"){
          OG2.push(i+1);
        }
      }
      console.log(OG1, OG1.length);
      console.log(OG2, OG2.length);
      
    })

    
    
  }
  catch(error) {
    console.log(error)
  }

  callback()
}