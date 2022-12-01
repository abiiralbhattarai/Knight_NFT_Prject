const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
describe("SquiresNftSetup", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploySquiresNft() {
    const baseURI = "https://www.pinata.cloud/";
    const _royaltyFeesInBips = 1000;
    const _royaltyReceiver = "0x78C206B6d21a5DAd5585803570D8555f21071C8c";

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const SquiresNft = await ethers.getContractFactory("GenZeroWizardNft");
    const SquiresNftContract = await SquiresNft.deploy(
      baseURI,
      _royaltyFeesInBips,
      _royaltyReceiver
    );

    return { SquiresNftContract, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { SquiresNftContract, owner } = await loadFixture(
        deploySquiresNft
      );

      expect(await SquiresNftContract.owner()).to.equal(owner.address);
    });
    it("Should Mint One Token ", async function () {
      const openSaleStatus = true;
      const { SquiresNftContract, owner } = await loadFixture(
        deploySquiresNft
      );
      await SquiresNftContract.setOpenSale(true);
      await SquiresNftContract.mint(1);
      expect(await SquiresNftContract.balanceOf(owner.address)).to.equal(1);
    });

    it("Should Burn One Nft ", async function () {
      const openSaleStatus = true;
      const { SquiresNftContract, owner } = await loadFixture(
        deploySquiresNft
      );
      await SquiresNftContract.setOpenSale(true);
      await SquiresNftContract.mint(5);
      await SquiresNftContract.burnToken(3, owner.address);
      expect(await SquiresNftContract.balanceOf(owner.address)).to.equal(4);
    });
    it("Should Return max NFT limit exceeded ", async function () {
      const openSaleStatus = true;
      const { SquiresNftContract, owner } = await loadFixture(
        deploySquiresNft
      );
      await SquiresNftContract.setOpenSale(true);
      await SquiresNftContract.mint(444);
    });
    it("Should minted amount equal to Total Supply", async function () {
      const openSaleStatus = true;
      const { SquiresNftContract, owner } = await loadFixture(
        deploySquiresNft
      );
      await SquiresNftContract.setOpenSale(true);
      await SquiresNftContract.mint(4);
     expect(await SquiresNftContract.totalSupplied()).to.equal(4);
    });
  });
});
