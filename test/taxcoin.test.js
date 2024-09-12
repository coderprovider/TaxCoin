const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("TaxCoinLock", function () {
    let taxCoinLock, TaxCoinLock, owner, addr1;

    const initialSupply = ethers.utils.parseEther("1000");

    beforeEach(async function () {
        // Get the ContractFactory and Signers

        taxCoinLock = await ethers.getContractFactory("TaxCoinLock");
        [owner, addr1] = await ethers.getSigners();

        // Deploy contract with initial supply
        taxCoinLock = await taxCoinLock.deploy(initialSupply);
        await taxCoinLock.deployed();
    });

    it("should deploy with the correct initial supply", async function () {
        const totalSupply = await taxCoinLock.totalSupply();
        expect(totalSupply).to.equal(initialSupply);
    });
});
