//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
/// @title Soliders Nft

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract SquiresNft is ERC721, Ownable {
    using Strings for uint256;
    string public baseURI;
    string public baseExtension = ".json";
    bool public openSale = false; //to pause the contract when needed
    uint256 public maxSupply = 444; //total Supply of Squires
    uint256 public totalSupplied; //total nft minted
    uint256 public pricePerNft = 0 ether;

    ///@dev for royalty
    uint256 royaltyFeesInBips;
    address royaltyReceiverAddress;
    mapping(address => uint256) public addressMintedBalance;
    // withdraw event
    event Withdrawl(uint256 amount);
    event NftMinted(address indexed user, uint256 amount);

    constructor(
        string memory _initBaseURI,
        uint256 _royaltyFeesInBips,
        address _royaltyReceiver
    ) ERC721("Knight Dungeon Squires", "KDS") {
        setBaseURI(_initBaseURI);
        royaltyFeesInBips = _royaltyFeesInBips;
        royaltyReceiverAddress = _royaltyReceiver;
    }

    /// @notice function to mint the nft
    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupplied;
        require(openSale, "the sale is closed");
        require(_mintAmount != 0, "need to mint at least 1 NFT");
        require(
            totalSupplied + _mintAmount <= maxSupply,
            "max NFT limit exceeded"
        );
        require(
            pricePerNft * _mintAmount <= msg.value,
            "Ether value is not sufficient"
        );
        for (uint256 i = 1; i <= _mintAmount; ++i) {
            addressMintedBalance[msg.sender]++;
            _safeMint(msg.sender, supply + i);
            totalSupplied = totalSupplied + 1;
        }
        emit NftMinted(msg.sender, _mintAmount);
    }

    /// @notice Royalty Codes

    /// @notice sets the informtion of the royalty
    /// @dev 1% is equal to 1*100 = 100 bips
    /// @param _royaltyReceiver reciever of the royalty
    /// @param _royaltyFeesInBips, fees in bips

    function setRoyaltyInfo(
        address _royaltyReceiver,
        uint256 _royaltyFeesInBips
    ) public onlyOwner {
        royaltyReceiverAddress = _royaltyReceiver;
        royaltyFeesInBips = _royaltyFeesInBips;
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        virtual
        returns (address, uint256)
    {
        return (royaltyReceiverAddress, calculateRoyalty(_salePrice));
    }

    function calculateRoyalty(uint256 _salePrice)
        public
        view
        returns (uint256)
    {
        return (_salePrice / 10000) * royaltyFeesInBips;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return
            interfaceId == 0x2a55205a || super.supportsInterface(interfaceId);
    }

    /// @notice change on the tokenUri
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    /// @notice burn the token
    /// @dev it is called by KnightNft Contract
    function burnToken(uint256 _tokenId, address _owner) public {
        require(ownerOf(_tokenId) == _owner, "not the nft owner");
        _burn(_tokenId);
    }

    /// @notice set the BaseUri
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    /// @notice change the openSale status
    function setOpenSale(bool _boolVlaue) public onlyOwner {
        openSale = _boolVlaue;
    }

    /// @notice sets the baseExtension
    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    /// @notice sets the price of Nft
    function setpricePerNft(uint256 _newCost) public onlyOwner {
        pricePerNft = _newCost;
    }

    /// @notice  function to withdraw ether
    function Withdraw() public payable onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer failed!");
        emit Withdrawl(amount);
    }

    /// @notice  returns the uri
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
