const { ethers } = require("hardhat");

async function main() {
  const TaxCoinLock = await ethers.getContractFactory("TaxCoinLock");
  const name = "TaxCoinLock";
  const symbol = "TAX";
  const initialSupply = ethers.parseEther("1000");
  const taxRate = 5;
  const taxCoinlock = await TaxCoinLock.deploy(name, symbol, initialSupply, taxRate);
  await taxCoinlock.waitForDeployment();
  console.log("Successful, TaxCoinDev deployed to:", taxCoinlock.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
