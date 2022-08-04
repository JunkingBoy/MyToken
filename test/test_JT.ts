import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import {BigNumber, ContractTransaction} from "ethers";
import {Contract} from "@ethersproject/contracts";

describe("JunToken", function () {
    const ZEROADDRESS = "0x0000000000000000000000000000000000000000";

    async function getAllNeed() {
        const tokenName = "FMJB";
        const tokenSymbol = "FMJB";

        const [owner, dev, third] = await ethers.getSigners();

        // Deploy chairman
        const ChairMan = await ethers.getContractFactory("ChairMan");
        const chairMan = await ChairMan.deploy();

        // Deploy FJMB
        const JTB = await ethers.getContractFactory("JunToken");
        const jtb = await JTB.deploy(chairMan.address, tokenName, tokenSymbol, BigNumber.from("10000000000000000000000"));

        // Deploy factory
        const LocalBankFactory = await ethers.getContractFactory("LocalBankFactory");
        const localBankFactory = await LocalBankFactory.deploy(chairMan.address, jtb.address);

        // Deploy center bank
        const CenterBank = await ethers.getContractFactory("CenterBank");
        const centerBank = await CenterBank.deploy(chairMan.address, localBankFactory.address);

        // Create local bank
        let index: ContractTransaction, localBank: ContractTransaction = await centerBank.createBank();
        console.log(localBank);
        console.log(localBank.toString());

        // Deploy china bank
        const ChinaBank = await ethers.getContractFactory("ChinaBank");
        const chinaBank = await ChinaBank.deploy(localBankFactory.address, 0, jtb.address);

        // Get local bank
        let localBankObject: Contract
        localBankObject = await ChinaBank.attach(localBank.toString());

        console.log(localBankObject);
        console.log(localBankObject.address);

        return { owner, dev, third, chairMan, jtb, localBankFactory, centerBank, chinaBank, localBank };
    }

    describe('test about JunToken', function () {
        it('user deposit', async function () {
            const {owner, dev, chairMan, jtb, centerBank, chinaBank, localBank } = await loadFixture(getAllNeed);

            expect(await chairMan.chairMan()).to.equal(owner.address);
        });
    });
});