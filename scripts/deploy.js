const hre = require("hardhat");

async function main() {
  const baseURI = "https://www.pinata.cloud/";
  const _royaltyFeesInBips = 1000;
  const _royaltyReceiver = "0x78C206B6d21a5DAd5585803570D8555f21071C8c";

  //for Squires Nft
  const squiresNft = await hre.ethers.getContractFactory("SquiresNft");
  const squiresNftContract = await squiresNft.deploy(
    baseURI,
    _royaltyFeesInBips,
    _royaltyReceiver
  );

  await squiresNftContract.deployed();

  //for Other Gen Knights
  const KnightNft = await hre.ethers.getContractFactory("KnightsNft");
  const KnightNftContract = await KnightNft.deploy(
    squiresNftContract.address,
    _royaltyFeesInBips,
    _royaltyReceiver
  );
  await KnightNftContract.deployed();

  //for Timelock Contract
  const min_Delay = 2;
  const proposersAddresses = ["0x78C206B6d21a5DAd5585803570D8555f21071C8c"];
  const ExecutorAddresses = ["0x78C206B6d21a5DAd5585803570D8555f21071C8c"];
  const NumberOfConfirmation = 1;
  const KnightExecutor = await hre.ethers.getContractFactory("KnightExecutor");
  const KnightExecutorContract = await KnightExecutor.deploy(
    min_Delay,
    proposersAddresses,
    ExecutorAddresses,
    NumberOfConfirmation
  );
  await KnightExecutorContract.deployed();

  //for Governance Contract
  const KnightGovernance = await hre.ethers.getContractFactory(
    "KnightGovernance"
  );
  const KnightGovernanceContract = await KnightGovernance.deploy(
    KnightNftContract.address,
    KnightExecutorContract.address
  );
  await KnightGovernanceContract.deployed();

  //for Armours Market Token Contract
  const ArmoursMarket = await hre.ethers.getContractFactory("ArmoursMarket");
  const ArmoursMarketContract = await ArmoursMarket.deploy(
    KnightNftContract.address
  );
  await ArmoursMarketContract.deployed();

  //for MagicArmours Token Contract
  const ArmoursToken = await hre.ethers.getContractFactory("ArmourTokens");
  const ArmoursTokenContract = await ArmoursToken.deploy(
    ArmoursMarketContract.address
  );
  await ArmoursTokenContract.deployed();

  // printing the address
  console.log(`Squires_NFT Contract: ${squiresNftContract.address}`);
  console.log(` Knight_NFT Contract: ${KnightNftContract.address}`);
  console.log(` Knight_Executor Contract: ${KnightExecutorContract.address}`);
  console.log(
    ` Knight_Governance Contract: ${KnightGovernanceContract.address}`
  );
  console.log(
    ` ArmoursToken Contract: ${ArmoursTokenContract.address}`
  );
  console.log(` ArmoursMarket Contract: ${ArmoursMarketContract.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
