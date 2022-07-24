import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

describe("JunToken", function () {
    const ZEROADDRESS = "0x0000000000000000000000000000000000000000";

    async function getJunToken() {
        const tokenName = "JTB";
        const tokenSymbol = "JTB";

        const [owner, dev, third] = await ethers.getSigners();

        const JTB = await ethers.getContractFactory("JunToken");
        const jtb = await JTB.deploy(tokenName, tokenSymbol, BigNumber.from("100000"));

        return { owner, dev, third, jtb };
    }

    describe("test deployment", function () {
        it('deploy jtb', async function() {
            const { owner, jtb } = await loadFixture(getJunToken);
            expect(await jtb.checkIssuer()).to.equal(owner.address);
        });
    });

    describe("test each functions", function () {
        it('send to dev', async function() {
            const { owner, dev, jtb } = await loadFixture(getJunToken);

            expect(await jtb.userBalance(owner.address)).to.equal(BigNumber.from("100000"));
            expect(await jtb.userBalance(dev.address)).to.equal(0);
            expect(await jtb.balanceOf(dev.address)).to.equal(0);
            await expect(jtb.addWhiteList(dev.address)).to.emit(jtb, "AddWhiteList");
            expect(await jtb.checkLicensor()).to.equal(1);
            await expect(jtb.connect(owner).sendToken(dev.address, BigNumber.from("10000"))).to.emit(jtb, "Sender");
            expect(await jtb.balanceOf(owner.address)).to.equal(BigNumber.from("100000").sub(BigNumber.from("10000")));
            expect(await jtb.userBalance(owner.address)).to.equal(BigNumber.from("100000").sub(BigNumber.from("10000")));
            expect(await jtb.balanceOf(dev.address)).to.equal(BigNumber.from("10000"));
            expect(await jtb.userBalance(dev.address)).to.equal(BigNumber.from("10000"));
        });

        it('send to zero', async function () {
            const { owner, jtb } = await loadFixture(getJunToken);

            expect(await jtb.userBalance(owner.address)).to.equal(BigNumber.from("100000"));
            await expect(jtb.connect(owner).sendToken(ZEROADDRESS, BigNumber.from("100000"))).to.emit(jtb, "Burn");
            expect(await jtb.userBalance(owner.address)).to.equal(0);
        });

        it('transfer to dev', async function () {
            const { dev, third, jtb } = await loadFixture(getJunToken);

            await jtb.addWhiteList(dev.address);
            await expect(jtb.translateToLicensor(dev.address)).to.emit(jtb, "TranslateToLicensor");
            expect(await jtb.checkLicensor()).to.equal(2);
            await jtb.sendToken(dev.address, BigNumber.from("10000"));
            await jtb.connect(dev).addWhiteList(third.address);
            await expect(jtb.tokenTransfer(dev.address, third.address, BigNumber.from("10"))).to.emit(jtb, "Transfer");
            await expect(jtb.connect(dev).tokenTransfer(dev.address, third.address, BigNumber.from("10"))).to.emit(jtb, "Transfer");
        });

        it('transfer to zero address', async function () {
            const { owner, jtb } = await loadFixture(getJunToken);

            await expect(jtb.tokenTransfer(owner.address, ZEROADDRESS, BigNumber.from("100000"))).to.emit(jtb, "Burn");
            expect(await jtb.balanceOf(owner.address)).to.equal(0);
        });

        it('transfer issuer', async function () {
            const { owner, dev, third, jtb } = await loadFixture(getJunToken);

            expect(await jtb.checkIssuer()).to.equal(owner.address);
            await expect(jtb.connect(dev).transferIssuer(third.address)).to.reverted;
            await jtb.connect(owner).sendToken(ZEROADDRESS, BigNumber.from("100000"));
            expect(await jtb.balanceOf(owner.address)).to.equal(0);
            await expect(jtb.connect(dev).sendToken(third.address, BigNumber.from("10000"))).to.reverted;
            await jtb.transferIssuer(dev.address);
            expect(await jtb.checkIssuer()).to.equal(dev.address);
            await expect(jtb.connect(owner).sendToken(third.address, BigNumber.from("10000"))).to.reverted;
        });
    });

    describe("test check user balance", function () {
        it('call the function check', async function () {
            const { owner, dev, jtb } = await loadFixture(getJunToken);

            expect(await jtb.balanceOf(dev.address)).to.equal(0);
            await jtb.addWhiteList(dev.address);
            await jtb.connect(owner).sendToken(dev.address, BigNumber.from("100"));
            expect(await jtb.balanceOf(dev.address)).to.equal(BigNumber.from("100"));

            expect(await jtb.checkUserBalance(dev.address)).to.equal(BigNumber.from("100"));
        });

        it("call the function award", async function () {
            const { owner, dev, jtb } = await loadFixture(getJunToken);

            let initBlock = await time.latestBlock();
            expect(await jtb.userBalance(owner.address)).to.equal(BigNumber.from("100000"));
            expect(await jtb.lastAwardBlock()).to.equal(await time.latestBlock());
            await expect(jtb.connect(dev).award(owner.address)).to.reverted;
            await expect(jtb.award(dev.address)).to.emit(jtb, "Award");
            let currentBlock = await jtb.lastAwardBlock();
            expect(await jtb.userBalance(dev.address)).to.equal(BigNumber.from(currentBlock).sub(initBlock));
        });
    });

    describe("test add user into white list", function () {
        it('call the function get white list', async function () {
            const { owner, dev, third, jtb } = await loadFixture(getJunToken);

            expect(await jtb.checkLicensor()).to.equal(1);
            let licensorAddress = await jtb.indexOfLicensor(0);
            expect(licensorAddress).to.equal(owner.address);
            await expect(jtb.addWhiteList(dev.address)).to.emit(jtb, "AddWhiteList");
            await expect(jtb.connect(dev).addWhiteList(third.address)).to.reverted;
            expect(await jtb.checkLicensor()).to.equal(1);
            let newLicensorAddress = await jtb.indexOfLicensor(0);
            expect(newLicensorAddress).to.equal(owner.address);
            await expect(jtb.translateToLicensor(dev.address)).to.emit(jtb, "TranslateToLicensor");
            expect(await jtb.checkLicensor()).to.equal(2);
            let licensorSecondAddress = await jtb.indexOfLicensor(1);
            expect(licensorSecondAddress).to.equal(dev.address);
            await expect(jtb.connect(dev).addWhiteList(third.address)).to.emit(jtb, "AddWhiteList");
            let toBeThird = await jtb.granteeByLicensor(dev.address, 0);
            expect(toBeThird).to.equal(third.address);
            await expect(jtb.sendToken(dev.address, BigNumber.from("100"))).to.emit(jtb, "Sender");
            expect(await jtb.balanceOf(dev.address)).to.equal(BigNumber.from("100"));

            await expect(jtb.sendToken(third.address, BigNumber.from("10"))).to.reverted;
            await expect(jtb.connect(dev).sendToken(third.address, BigNumber.from("10"))).to.emit(jtb, "Sender");
            await expect(jtb.connect(dev).tokenTransfer(dev.address, third.address, BigNumber.from("10"))).to.emit(jtb, "Transfer");
            await expect(jtb.connect(dev).sendToken(ZEROADDRESS, BigNumber.from("10"))).to.emit(jtb, "Burn");
            await expect(jtb.connect(dev).tokenTransfer(dev.address, ZEROADDRESS, BigNumber.from("10"))).to.emit(jtb, "Burn");
            expect(await jtb.balanceOf(dev.address)).to.equal(BigNumber.from("60"));
        });

        it('call the function remove white list', async function () {
            const { dev, third, jtb } = await loadFixture(getJunToken);

            await expect(jtb.addWhiteList(dev.address)).to.emit(jtb, "AddWhiteList");
            await expect(jtb.addWhiteList(third.address)).to.emit(jtb, "AddWhiteList");
            await expect(jtb.translateToLicensor(dev.address)).to.emit(jtb, "TranslateToLicensor");
            await expect(jtb.connect(dev).addWhiteList(third.address)).to.emit(jtb, "AddWhiteList");

            await expect(jtb.connect(dev).removeWhiteList(dev.address, third.address)).to.reverted;
            await expect(jtb.removeWhiteList(dev.address, third.address)).to.emit(jtb, "RemoveWhiteList");
            expect(await jtb.granteeByLicensor(dev.address, 0)).to.equal(ZEROADDRESS);
            await expect(jtb.sendToken(dev.address, BigNumber.from("100"))).to.emit(jtb, "Transfer");
            await expect(jtb.tokenTransfer(dev.address, third.address, BigNumber.from("10"))).to.reverted;
        });

        it('call the function remove white list but not exit', async function () {
            const { owner, dev, third, jtb } = await loadFixture(getJunToken);

            await expect(jtb.addWhiteList(dev.address)).to.emit(jtb, "AddWhiteList");
            await expect(jtb.translateToLicensor(dev.address)).to.emit(jtb, "TranslateToLicensor");
            await expect(jtb.connect(dev).addWhiteList(third.address)).to.emit(jtb, "AddWhiteList");

            await expect(jtb.connect(dev).removeWhiteList(dev.address, third.address)).to.reverted;
            await expect(jtb.removeWhiteList(dev.address, third.address)).to.emit(jtb, "RemoveWhiteList");
            await expect(jtb.removeWhiteList(owner.address, third.address)).to.not.emit(jtb, "RemoveWhiteList");
        });

        it('call the function check length', async function () {
            const { owner, dev, jtb } = await loadFixture(getJunToken);

            await expect(jtb.addWhiteList(dev.address)).to.emit(jtb, "AddWhiteList");
            expect(await jtb.checkGranteeLength(owner.address)).to.equal(1);
        });
    });
});