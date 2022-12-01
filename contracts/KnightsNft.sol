//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/governance/utils/Votes.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./IERC4907.sol";
import "./SquiresNft.sol";

contract KnightsNft is ERC721URIStorage, Ownable, IERC4907, Votes {
   SquiresNft private _nftContract;

    using Strings for uint256;
    string public baseURI;
    string public baseExtension = ".json";
    uint256 public maxSupply = 5555; //total Supply of Knights
    uint256 public totalSupplied; //total supplied
    // withdraw event
    event Withdrawl(uint256 amount);

    /**
     * @dev prices of the nft
     */
    uint256 public GenOnePrice = 0.1 ether;
    uint256 public GenTwoPrice = 0.2 ether;
    uint256 public GenThreePrice = 0.3 ether;

    ///@dev for royalty
    uint256 royaltyFeesInBips;
    address royaltyReceiverAddress;

    bool public openSale = false; //to pause the contract when needed

    /**
     * @dev Emitted when theSquires Nft  address is changed
     */
    event SquiresContractChanged(
        address oldNftContract,
        address newNftContract
    );

    /**
     * @dev character attributes
     */
    struct Attributes {
        string name;
        string generation; //generation of the Knights
        string description; //description of the NFT
        string image; //generation of the image
        uint256 rank; //rank of the NFT Knights
        string KnightsType; //Knights Types
    }

    /// @notice userInfo of user who needs nft in rent
    struct UserInfo {
        address user; // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    mapping(uint256 => UserInfo) internal _users;
    //mapping of the attributes
    mapping(uint256 => Attributes) public attributes;
    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /// @dev provide nft contract address ofSquires Nft
    /// @param _royaltyFeesInBips  1% is equal to 1*100 = 100 bips
    constructor(
       SquiresNft _squiresContractAddress,
        uint256 _royaltyFeesInBips,
        address _royaltyReceiver
    ) ERC721("Knights NFT Dungeon", "KND") EIP712("Knights NFT Dungeon", "1") {
        _nftContract = _squiresContractAddress;
        royaltyFeesInBips = _royaltyFeesInBips;
        royaltyReceiverAddress = _royaltyReceiver;
    }

    /// @notice Nft mint function
    function mint(uint256 _mintAmount) public payable {
        uint256 newItemId = totalSupplied;
        require(openSale, "the sale is closed");
        require(_mintAmount != 0, "need to mint at least 1 NFT");
        require(newItemId + _mintAmount <= maxSupply, "max NFT limit exceeded");
        for (uint256 i = 1; i <= _mintAmount; ++i) {
            require(
                pricePerNft(newItemId) * _mintAmount <= msg.value,
                "Ether value is not sufficient"
            );
            attributes[newItemId + i] = Attributes(
                "Revolting Knights",
                setGeneration(newItemId + i),
                setDescription(newItemId + i),
                setImage(newItemId + i),
                0,
                "Default"
            );
            _safeMint(msg.sender, newItemId + i);
            _setTokenURI(newItemId + i, buildMetaData(newItemId + i));
            totalSupplied = totalSupplied + 1;
        }
    }

    /**
     * @dev burnt function of NFT
     */
    function burntMint(uint256[] memory _tokenIds) public {
        uint256 newItemId = totalSupplied;
        require(openSale, "the sale is closed");
        require(newItemId + _tokenIds.length <= 1200, "max NFT limit exceeded");
        require(totalSupplied <= 1200, "Gen One Knights already Minted");

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 j = i + 1;
            require(
                _nftContract.ownerOf(_tokenIds[i]) == msg.sender,
                "Not the owner of NFT"
            );
            _nftContract.burnToken(_tokenIds[i], msg.sender);
            attributes[newItemId + j] = Attributes(
                "Gen Knights",
                setGeneration(newItemId + j),
                setDescription(newItemId + j),
                setImage(newItemId + j),
                0,
                "Default"
            );
            _safeMint(msg.sender, newItemId + j);
            _setTokenURI(newItemId + j, buildMetaData(newItemId + j));
            totalSupplied = totalSupplied + 1;
        }
    }

    ///@notice Royalty Codes

    ///@notice sets the informtion of the royalty
    ///@dev 1% is equal to 1*100 = 100 bips
    /// @param _royaltyReceiver reciever of the royalty
    ///@param _royaltyFeesInBips, fees in bips

    function setRoyaltyInfo(
        address _royaltyReceiver,
        uint256 _royaltyFeesInBips
    ) public onlyOwner {
        royaltyReceiverAddress = _royaltyReceiver;
        royaltyFeesInBips = _royaltyFeesInBips;
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view virtual returns (address, uint256) {
        return (royaltyReceiverAddress, calculateRoyalty(_salePrice));
    }

    function calculateRoyalty(
        uint256 _salePrice
    ) public view returns (uint256) {
        return (_salePrice / 10000) * royaltyFeesInBips;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return
            interfaceId == 0x2a55205a || super.supportsInterface(interfaceId);
    }

    ///@notice NFT rental code starts

    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) public virtual override {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        require(userOf(tokenId) == address(0), "User already assigned");
        require(expires > block.timestamp, "expires should be in future");
        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(
        uint256 tokenId
    ) public view virtual override returns (address) {
        if (uint256(_users[tokenId].expires) >= block.timestamp) {
            return _users[tokenId].user;
        } else {
            return address(0);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(
        uint256 tokenId
    ) public view virtual override returns (uint256) {
        return _users[tokenId].expires;
    }

    /**
     * @dev to get the price according to the generation
     */
    function pricePerNft(uint256 tokenId) public view returns (uint256) {
        if (tokenId <= 1200) {
            return GenOnePrice;
        } else if (tokenId > 1200 && tokenId <= 2644) {
            return GenTwoPrice;
        } else {
            return GenThreePrice;
        }
    }

    /**
     * @dev set the description of the Nft
     */
    function setDescription(
        uint256 _tokenId
    ) public pure returns (string memory) {
        if (_tokenId <= 1200) {
            return "GenOnePrice";
        } else if (_tokenId > 1200 && _tokenId <= 2644) {
            return "GenTwoPrice";
        } else {
            return "GenThreePrice";
        }
    }

    /**
     * @dev set the generation of the Nft
     */
    function setGeneration(
        uint256 _tokenId
    ) public pure returns (string memory) {
        if (_tokenId <= 1200) {
            return "Gen 1";
        } else if (_tokenId > 1200 && _tokenId <= 2644) {
            return "Gen 2";
        } else {
            return "Gen 3";
        }
    }

    /**
     * @dev set the image of the Nft
     */
    function setImage(uint256 _tokenId) public pure returns (string memory) {
        return
            "https://ipfs.io/ipfs/QmeWK2BwtsEsSmRDMwmwCT5PADbyku2Xik5sXtsVQVC9Gw?filename=HE-SLEEP.jpeg";
    }

    /**
     * @dev generates the metadata of the Nft
     */
    function buildMetaData(
        uint256 tokenId
    ) public view returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        attributes[tokenId].name,
                        '",',
                        '"image": "',
                        attributes[tokenId].image,
                        '",',
                        '"description": "',
                        attributes[tokenId].description,
                        '",',
                        '"attributes": [{"trait_type": "Generation", "value": "',
                        attributes[tokenId].generation,
                        '"},',
                        '{"trait_type": "Rank", "value": ',
                        uintTostr(attributes[tokenId].rank),
                        "},",
                        '{"trait_type": "Knights", "value": "',
                        attributes[tokenId].KnightsType,
                        '"}',
                        "]}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    /**
     * @dev set genone price
     */
    function setGenOnePrice(uint256 _newGenOnePrice) public onlyOwner {
        GenOnePrice = _newGenOnePrice;
    }

    /**
     * @dev set gentwo price
     */
    function setGenTwoPrice(uint256 _newGenTwoPrice) public onlyOwner {
        GenTwoPrice = _newGenTwoPrice;
    }

    /**
     * @dev set genthree price
     */
    function setGenThreePrice(uint256 _newGenThreePrice) public onlyOwner {
        GenThreePrice = _newGenThreePrice;
    }

    /**
     * @dev set Pause Open
     */
    function setOpenSale(bool _boolVlaue) public onlyOwner {
        openSale = _boolVlaue;
    }

    /**
     * @dev to withdraw fund
     */
    function withdraw() public payable onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer failed!");
        emit Withdrawl(amount);
    }

    /**
     * @dev set the description of the Nft
     */
    function getMintingGenration() public view returns (string memory) {
        if (totalSupplied <= 1200) {
            return "Gen One Minting";
        } else if (totalSupplied > 1200 && totalSupplied <= 2644) {
            return "Gen TWO Minting";
        } else {
            return "Gen Three Minting";
        }
    }

    /**
     * @dev update Squires nft contract
     */
    function _updateSquiresContract(SquiresNft newNftContract) public {
        emit SquiresContractChanged(
            address(_nftContract),
            address(newNftContract)
        );
        _nftContract = newNftContract;
    }

    //@dev upgrade rank
    function upgradeRank(uint256 level, uint256 _tokenId) public {
        if (level == 1) {
            upgraedToOne(_tokenId);
        }
    }

    //@dev change the name fo the nft
    function upgraedToOne(uint256 _tokenId) internal {
        attributes[_tokenId] = Attributes(
            attributes[_tokenId].name,
            attributes[_tokenId].generation,
            attributes[_tokenId].description,
            attributes[_tokenId].image,
            1,
            attributes[_tokenId].KnightsType
        );
        _setTokenURI(_tokenId, buildMetaData(_tokenId));
    }

    //@dev change the name fo the nft
    function changeNFTName(uint256 _tokenId, string memory _name) public {
        attributes[_tokenId] = Attributes(
            _name,
            attributes[_tokenId].generation,
            attributes[_tokenId].description,
            attributes[_tokenId].image,
            attributes[_tokenId].rank,
            attributes[_tokenId].KnightsType
        );
        _setTokenURI(_tokenId, buildMetaData(_tokenId));
    }

    /**
     * @dev Adjusts votes when tokens are transferred.
     *
     * Emits a {Votes-DelegateVotesChanged} event.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        _transferVotingUnits(from, to, 1);
        super._afterTokenTransfer(from, to, tokenId);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Returns the balance of `account`.
     */
    function _getVotingUnits(
        address account
    ) internal view virtual override returns (uint256) {
        return balanceOf(account);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
    }

    /**
     * @dev convert the uint to string
     */
    function uintTostr(
        uint _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
