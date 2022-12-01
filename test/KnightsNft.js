const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  const { ethers } = require("hardhat");
  
  describe("KnightsNftTesting", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
  
    async function deployNftContract() {
      const baseURI = "https://www.pinata.cloud/";
      const _royaltyFeesInBips = 1000;
      const _royaltyReceiver = "0x78C206B6d21a5DAd5585803570D8555f21071C8c";
  
      // Contracts are deployed using the first signer/account by default
      const SquiresNft= await ethers.getContractFactory("SquiresNft");
      const SquiresNftContract = await GenzeroWizard.deploy(
        baseURI,
        _royaltyFeesInBips,
        _royaltyReceiver
      );
      const [owner, otherAccount] = await ethers.getSigners();
      const KnightsNft = await ethers.getContractFactory("KnightsNft");
      const KnightsNftContract = await KnightsNft.deploy(
        SquiresNftContract.address,
        _royaltyFeesInBips,
        _royaltyReceiver
      );
      return { KnightsNftContract, SquiresNftContract, owner, otherAccount };
    }
  
    describe("Deployment", function () {
      it("Should set the right owner", async function () {
        const { KnightsNftContract, owner } = await loadFixture(deployNftContract);
  
        expect(await KnightsNftContract.owner()).to.equal(owner.address);
      });
    });
    describe("Generation One Nft", function () {
      this.timeout(200000);
      it("Should mint Generation One Nft with correct balance", async function () {
        const { KnightsNftContract, owner } = await loadFixture(deployNftContract);
        await KnightsNftContract.setOpenSale(true);
  
        const options = {
          value: ethers.utils.parseEther("5"),
        };
        const optionsNft = {
          value: ethers.utils.parseEther("10"),
        };
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, optionsNft);
        await KnightsNftContract.mint(50, optionsNft);
        await KnightsNftContract.mint(50, optionsNft);
        await KnightsNftContract.mint(50, optionsNft);
        const balance = (await KnightsNftContract.getBalance()).toString();
        const actualBalance = ethers.utils.formatUnits(balance, "ether");
        expect(await KnightsNftContract.balanceOf(owner.address)).to.equal(1400);
        expect(actualBalance).to.equal("160.0");
      });
      it("Should set Generation Correctly", async function () {
        const { KnightsNftContract, owner } = await loadFixture(deployNftContract);
        expect(await KnightsNftContract.setGeneration(1200)).to.equal("Gen 1");
        expect(await KnightsNftContract.setGeneration(1201)).to.equal("Gen 2");
        expect(await KnightsNftContract.setGeneration(2644)).to.equal("Gen 2");
        expect(await KnightsNftContract.setGeneration(2645)).to.equal("Gen 3");
        expect(await KnightsNftContract.setGeneration(4444)).to.equal("Gen 3");
      });
    });
    describe("Test Burnt Mint", function () {
      this.timeout(200000);
      it("Should Mint One GenOne Knigth Nft For One Squire Nft ", async function () {
        const { KnightsNftContract, SquiresNftContract, owner } =
          await loadFixture(deployNftContract);
        await SquiresNftContract.setOpenSale(true);
        await SquiresNftContract.mint(3);
        expect(await SquiresNftContract.balanceOf(owner.address)).to.equal(3);
        await KnightsNftContract.setOpenSale(true);
        const options = {
          value: ethers.utils.parseEther("5"),
        };
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(50, options);
        await KnightsNftContract.mint(49, options);
        await KnightsNftContract.burntMint([3]);
        expect(await KnightsNftContract.balanceOf(owner.address)).to.equal(1200);
        expect(await SquiresNftContract.balanceOf(owner.address)).to.equal(2);
      });
    });
  });
  