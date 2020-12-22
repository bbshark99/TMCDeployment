pragma solidity ^0.6.12;

import "@openzeppelin/contracts/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./MyOwnable.sol";

contract TMA is 
    ERC1155PresetMinterPauser("https://us-central1-nfgotchi-c88dd.cloudfunctions.net/widgets/resource/tma/{id}"), 
    MyOwnable
{
    using SafeMath for uint256;

    string public name;
    string public symbol;
    mapping (uint256 => uint256) public tokenSupply;

    constructor(string memory _name, string memory _symbol, address owner) public MyOwnable(owner) {
        name = _name;
        symbol = _symbol;

        // _setupRole(DEFAULT_ADMIN_ROLE, owner);
        // _setupRole(MINTER_ROLE, owner);
        // _setupRole(PAUSER_ROLE, owner);
        
        // // deployed via eth.deployer
        // address a = _msgSender();
        // renounceRole(DEFAULT_ADMIN_ROLE,a);
        // renounceRole(MINTER_ROLE,a);
        // renounceRole(PAUSER_ROLE,a);
    }

    function setURI(string memory uri) public onlyOwner{
        _setURI(uri);
    }

    function totalSupply(
        uint256 _id
    ) public view returns (uint256) {
        return tokenSupply[_id];
    }

    function mint(address _to, uint256 _id, uint256 _quantity, bytes memory _data) public override onlyOwner{
        _mint(_to, _id, _quantity, _data);
        tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    }
    
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public override onlyOwner{
        _mintBatch(to, ids, amounts, data);
        for (uint256 i = 0; i < ids.length; i++){
            tokenSupply[ids[i]] = tokenSupply[ids[i]].add(amounts[i]);
        }
    }

    function burn(address account, uint256 id, uint256 value) public override{
        ERC1155Burnable.burn(account, id, value);
        tokenSupply[id] = tokenSupply[id].sub(value);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) public override {
        ERC1155Burnable.burnBatch(account, ids, values);
        for (uint256 i = 0; i < ids.length; i++){
            tokenSupply[ids[i]] = tokenSupply[ids[i]].sub(values[i]);
        }
    }

    mapping(uint256 => uint256) public bonusEffect;
    function setBonusEffect(uint256 tokenId, uint256 amt) public onlyOwner{
        bonusEffect[tokenId] = amt;
    }
    function close() public onlyOwner { 
        address payable p = payable(owner());
        selfdestruct(p); 
    }
}