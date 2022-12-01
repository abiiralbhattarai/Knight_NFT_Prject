// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract ArmourTokens is ERC1155, Ownable, ERC1155Supply {
    string public name;
    string public symbol;
    string private baseUri;
    address public ArmourMarketContract;
    address public contractOwner;

    //to allow only the ArmoursMarket contract to mint
    modifier mintingContract() {
        require(
            msg.sender == ArmourMarketContract,
            "You are not authorized to call function"
        );
        _;
    }

    mapping(uint => string) public tokenURI;

    ///@notice  aemour tokens for knights 
    uint8 public constant Head_Armour = 1;
    uint8 public constant Chest_Armour = 2;
    uint8 public constant Arm_Armour = 3;
    uint8 public constant Gloves_Armour = 4;
    uint8 public constant Centre_Armour = 5;
    uint8 public constant Thigh_Armour = 6;
    uint8 public constant Leg_Armour = 7;
    uint8 public constant boot_Armour = 8;
 

    constructor(address _receiverContract) ERC1155("") {
        name = "Knight Armours";
        symbol = "KAR";
        baseUri = "https://bafybeihul6zsmbzyrgmjth3ynkmchepyvyhcwecn2yxc57ppqgpvr35zsq.ipfs.dweb.link/";
        ArmourMarketContract = _receiverContract;
    }

    ///@notice function to mint ArmoursToken in Batches
    function mintBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external mintingContract {
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );
        for (uint256 i = 0; i < ids.length; i++) {
            require(amounts[i] > 0, "Amount should be greater than One");
        }
        _mintBatch(account, ids, amounts, "");
        for (uint256 i = 0; i < ids.length; i++) {
            tokenURI[ids[i]] = setTokenuri(ids[i]);
        }
    }

    ///@notice function to burn ArmoursToken in Batches
    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external mintingContract {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burnBatch(account, ids, amounts);
    }

    function setNewBaseUri(string memory _newUri) public onlyOwner {
        baseUri = _newUri;
    }

    function setNewReceiverContract(string memory _newUri) public onlyOwner {
        baseUri = _newUri;
    }

    function setTokenuri(uint256 _tokenid)
        internal
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(baseUri, Strings.toString(_tokenid), ".json")
            );
    }

    function setArmoursMarketContract(address contractAddress) public onlyOwner {
        ArmourMarketContract= contractAddress;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
