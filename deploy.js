
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

// let tamagAdd = "0xa6D82Fc1f99A868EaaB5c935fe7ba9c9e962040E";
// const rewardcalc = web3.eth.abi.encodeParameters(['address'], [tamagAdd]);
// console.log("rewardcalc", rewardcalc);

web3.eth.getBlockNumber().then((block) => {
    console.log(block);
    const now = Math.floor(Date.now()/1000);
    const target = 1607785200 - 600; // 5min buffer for block drift 
    let targetBlock = block + Math.floor((target-now)/15);
    console.log("targetBlock", targetBlock)
    let tmcAdd = "0x1dD68a5686B21fCe36cEc6CD5761782d3D57eE38"
    let devAdd = "0xC2884De64ceFF15211Bb884a1E84F5aeaD9fdc7c"
    let tmcPerBlock = "40000000000000000000"
    let startBlock = targetBlock
    let bonusEndBlock = targetBlock+1
    let rewardCalcAdd = "0x09C1FF2bb287593A931B2dfcA8E1fc4E764F45d3"
    const pool = web3.eth.abi.encodeParameters(['address','address','uint256','uint256','uint256','address'], 
        [tmcAdd,devAdd,tmcPerBlock,startBlock,bonusEndBlock,rewardCalcAdd]);
    console.log("pool", pool);
})