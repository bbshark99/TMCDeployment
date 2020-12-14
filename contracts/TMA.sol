pragma solidity ^0.6.12;

import "@openzeppelin/contracts/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "./ERC20Governance.sol";
import "./ERC20TransferLiquidityLock.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./IUnicrypt.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TMA is 
    ERC1155PresetMinterPauser("https://us-central1-nfgotchi-c88dd.cloudfunctions.net/widgets/resource/tma/{id}"), 
    Ownable
{
    using SafeMath for uint256;

    string public name;
    string public symbol;
    mapping (uint256 => uint256) public tokenSupply;

    constructor(string memory _name, string memory _symbol) public {
        name = _name;
        symbol = _symbol;
    }

    function setURI(string memory uri) public onlyOwner{
        _setURI(uri);
    }

    function totalSupply(
        uint256 _id
    ) public view returns (uint256) {
        return tokenSupply[_id];
    }

    function mint(address _to, uint256 _id, uint256 _quantity, bytes memory _data) public override{
        _mint(_to, _id, _quantity, _data);
        tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    }
    
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public override{
        mintBatch(to, ids, amounts, data);
        for (uint256 i = 0; i < ids.length; i++){
            tokenSupply[ids[i]].sub(amounts[i]);
        }
    }

    function burn(address account, uint256 id, uint256 value) public override{
        burn(account, id, value);
        tokenSupply[id] = tokenSupply[id].sub(value);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) public override {
        burnBatch(account, ids, values);
        for (uint256 i = 0; i < ids.length; i++){
            tokenSupply[ids[i]].sub(values[i]);
        }
    }



    // function uri(uint256 i) public virtual view override(ERC1155) returns (string memory) {
    //     return uri(i);
    // }

    // function _beforeTokenTransfer(
    //     address operator,
    //     address from,
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory amounts,
    //     bytes memory data
    // )
    //     internal override(ERC1155, ERC1155PresetMinterPauser)
    // {
    //     super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    // }
}