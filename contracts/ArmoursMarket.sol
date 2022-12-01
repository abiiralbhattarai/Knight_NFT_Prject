//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
/// @title contract to buy JewelsToken

import "./KnightsNft.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./ArmourTokens.sol";

contract ArmourssMarket is ERC1155Holder, Ownable {
    ///@notice balance of the Armour
    uint256 public Head_Armour_Balance;
    uint256 public Chest_Armour_Balance;
    uint256 public Arm_Armour_Balance;
    uint256 public Gloves_Armour_Balance;
    uint256 public Centre_Armour_Balance;
    uint256 public Thigh_Armour_Balance;
    uint256 public Leg_Armour_Balance;
    uint256 public boot_Armour_Balance;

    ///@notice total supply of Armour
    uint256 public Head_Armour_Supply;
    uint256 public Chest_Armour_Supply;
    uint256 public Arm_Armour_Supply;
    uint256 public Gloves_Armour_Supply;
    uint256 public Centre_Armour_Supply;
    uint256 public Thigh_Armour_Supply;
    uint256 public Leg_Armour_Supply;
    uint256 public boot_Armour_Supply;

    ///@notice price of the Armour
    uint256 public Head_Armour_Price = 0 ether;
    uint256 public Chest_Armour_Price = 0 ether;
    uint256 public Arm_Armour_Price = 0 ether;
    uint256 public Gloves_Armour_Price = 0 ether;
    uint256 public Centre_Armour_Price = 0 ether;
    uint256 public Thigh_Armour_Price = 0 ether;
    uint256 public Leg_Armour_Price = 0 ether;
    uint256 public boot_Armour_Price = 0 ether;

    KnightsNft public knightsNft;
    ArmourTokens public armoursToken;
    address public armoursMarketContract;

    mapping(uint256 => uint256[]) public armourTokens; //armour of a nft Id
    mapping(uint256 => mapping(uint256 => uint256)) //armour quantity of nftId
        public armourTokensQuantity;
    mapping(uint256 => mapping(uint256 => bool)) public armourTokensCheck;

    constructor(KnightsNft _knightsNftContractAddress) {
        knightsNft = _knightsNftContractAddress;
    }

    /**
     * @notice to buy the armour token
     */
    function armourMint(
        uint256 nftId,
        uint256[] memory armourTokenIds,
        uint256[] memory mintAmount
    ) public payable {
        require(
            knightsNft.ownerOf(nftId) == msg.sender,
            "You are not the owner"
        );
        for (uint256 i = 0; i < armourTokenIds.length; i++) {
            require(mintAmount[i] > 0, "need to mint at least 1 Token");
            uint256 itemBalance = getTokenSupply(armourTokenIds[i]);
            require(
                itemBalance + mintAmount[i] <=
                    getTokenBalance(armourTokenIds[i])
            );
            require(armourTokenIds[i] <= 8, "Not Jewels for Wizard");

            require(
                armourPrice(armourTokenIds[i]) * mintAmount[i] <= msg.value,
                "Ether value is not sufficient"
            );
            addWizardJewels(nftId, armourTokenIds[i]);
            armourTokensQuantity[nftId][armourTokenIds[i]] += mintAmount[i];
            _adjustTokenBalance(armourTokenIds[i], mintAmount[i]);
        }
    }

    ///@notice get the Armour Token from MagicJewelsToken Contract(increasing the token number)
    function mintArmourToken(
        uint256[] memory tokenIds,
        uint256[] memory mintAmount
    ) public onlyOwner {
        require(
            armoursMarketContract != address(0),
            "jewels Market Contract not set"
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] > 0 && tokenIds[i] <= 15, "Invalid token Id");
            require(mintAmount[i] > 0, "Amount should be greater than One");
        }
        armoursToken.mintBatch(armoursMarketContract, tokenIds, mintAmount);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _adjustMintBalance(tokenIds[i], mintAmount[i]);
        }
    }

    ///@notice burn the jewels from MagicJewelsToken Contract
    function burnJewels(
        uint256[] memory tokenIds,
        uint256[] memory amount
    ) public onlyOwner {
        require(
            armoursMarketContract != address(0),
            "jewels Market Contract not set"
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] > 0 && tokenIds[i] <= 15, "Invalid token Id");
            require(amount[i] > 0, "Amount should be greater than One");
            require(
                amount[i] <= getTokenBalance(tokenIds[i]),
                "Token not available to burn"
            );
        }
        armoursToken.burnBatch(armoursMarketContract, tokenIds, amount);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _adjustBurntBalance(tokenIds[i], amount[i]);
        }
    }

    /**
     * @notice to get the price according to the wizard jewels
     */
    function armourPrice(uint256 tokenId) public view returns (uint256) {
        if (tokenId == 1) {
            return Head_Armour_Price;
        } else if (tokenId == 2) {
            return Chest_Armour_Price;
        } else if (tokenId == 3) {
            return Arm_Armour_Price;
        } else if (tokenId == 4) {
            return Gloves_Armour_Price;
        } else if (tokenId == 5) {
            return Centre_Armour_Price;
        } else if (tokenId == 6) {
            return Thigh_Armour_Price;
        } else if (tokenId == 7) {
            return Leg_Armour_Price;
        } else {
            return boot_Armour_Price;
        }
    }

    /**
     * @notice to get the price according to the demon jewels
     */
    function addWizardJewels(uint256 nftTokenId, uint256 jewelsTokenId) public {
        if (armourTokensCheck[nftTokenId][jewelsTokenId] != true) {
            armourTokens[nftTokenId].push(jewelsTokenId);
            armourTokensCheck[nftTokenId][jewelsTokenId] = true;
        }
    }

    /**
     * @notice to get the balance of token
     */
    function getTokenBalance(uint256 tokenId) public view returns (uint256) {
        if (tokenId == 1) {
            return Head_Armour_Balance;
        } else if (tokenId == 2) {
            return Chest_Armour_Balance;
        } else if (tokenId == 3) {
            return Arm_Armour_Balance;
        } else if (tokenId == 4) {
            return Gloves_Armour_Balance;
        } else if (tokenId == 5) {
            return Centre_Armour_Balance;
        } else if (tokenId == 6) {
            return Thigh_Armour_Balance;
        } else if (tokenId == 7) {
            return Leg_Armour_Balance;
        } else {
            return boot_Armour_Balance;
        }
    }

    /**
     * @notice to get the supply of token
     */
    function getTokenSupply(uint256 tokenId) public view returns (uint256) {
        if (tokenId == 1) {
            return Head_Armour_Supply;
        } else if (tokenId == 2) {
            return Chest_Armour_Supply;
        } else if (tokenId == 3) {
            return Arm_Armour_Supply;
        } else if (tokenId == 4) {
            return Gloves_Armour_Supply;
        } else if (tokenId == 5) {
            return Centre_Armour_Supply;
        } else if (tokenId == 6) {
            return Thigh_Armour_Supply;
        } else if (tokenId == 7) {
            return Leg_Armour_Supply;
        } else {
            return boot_Armour_Supply;
        }
    }

    /**
     * @notice to adjust the balance of token after user mint token
     */
    function _adjustTokenBalance(uint256 tokenId, uint256 amount) internal {
        if (tokenId == 1) {
            Head_Armour_Balance -= amount;
            Head_Armour_Supply += amount;
        } else if (tokenId == 2) {
            Chest_Armour_Balance -= amount;
            Chest_Armour_Supply += amount;
        } else if (tokenId == 3) {
            Arm_Armour_Balance -= amount;
            Arm_Armour_Supply += amount;
        } else if (tokenId == 4) {
            Gloves_Armour_Balance -= amount;
            Gloves_Armour_Supply += amount;
        } else if (tokenId == 5) {
            Centre_Armour_Balance -= amount;
            Centre_Armour_Supply += amount;
        } else if (tokenId == 6) {
            Thigh_Armour_Balance -= amount;
            Thigh_Armour_Supply += amount;
        } else if (tokenId == 7) {
            Leg_Armour_Balance -= amount;
            Leg_Armour_Supply += amount;
        } else {
            boot_Armour_Balance -= amount;
            boot_Armour_Supply += amount;
        }
    }

    /**
     * @notice to adjust the balance of token after contract mint token from Magic Jewels Token Contract
     */
    function _adjustMintBalance(uint256 tokenId, uint256 amount) internal {
        if (tokenId == 1) {
            Head_Armour_Balance += amount;
        } else if (tokenId == 2) {
            Chest_Armour_Balance += amount;
        } else if (tokenId == 3) {
            Arm_Armour_Balance += amount;
        } else if (tokenId == 4) {
            Gloves_Armour_Balance += amount;
        } else if (tokenId == 5) {
            Centre_Armour_Balance += amount;
        } else if (tokenId == 6) {
            Thigh_Armour_Balance += amount;
        } else if (tokenId == 7) {
            Leg_Armour_Balance += amount;
        } else {
            boot_Armour_Balance += amount;
        }
    }

    /**
     * @notice to adjust the balance of token after burning token from Magic Jewels Token Contract
     */
    function _adjustBurntBalance(uint256 tokenId, uint256 amount) internal {
        if (tokenId == 1) {
            Head_Armour_Balance -= amount;
        } else if (tokenId == 2) {
            Chest_Armour_Balance -= amount;
        } else if (tokenId == 3) {
            Arm_Armour_Balance -= amount;
        } else if (tokenId == 4) {
            Gloves_Armour_Balance -= amount;
        } else if (tokenId == 5) {
            Centre_Armour_Balance -= amount;
        } else if (tokenId == 6) {
            Thigh_Armour_Balance -= amount;
        } else if (tokenId == 7) {
            Leg_Armour_Balance -= amount;
        } else {
            boot_Armour_Balance -= amount;
        }
    }

    ///@notice set the armoursToken contract
    function setarmoursToken(
        ArmourTokens _armourContractAddress
    ) public onlyOwner {
        armoursToken = _armourContractAddress;
    }

    ///@notice setting the ArmoursMarket Contract for minting and burning
    function setJewelsMarketContract(
        address _armoursMarketAddress
    ) public onlyOwner {
        armoursMarketContract = _armoursMarketAddress;
    }

    ///@notice get the jewels of wizard Nft
    function getWizardJewelsToken(
        uint256 nftId,
        address userAddress
    ) public view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory tokenOwned = new uint256[](armourTokens[nftId].length);
        uint256[] memory tokenQuantity = new uint256[](
            armourTokens[nftId].length
        );
        require(
            knightsNft.ownerOf(nftId) == userAddress,
            "You are not the owner of Wizard nft"
        );
        for (uint256 i = 0; i < armourTokens[nftId].length; i++) {
            tokenOwned[i] = armourTokens[nftId][i];
            tokenQuantity[i] = armourTokensQuantity[nftId][tokenOwned[i]];
        }
        return (tokenOwned, tokenQuantity);
    }
}
