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
            const { owner, dev, jtb } = await loadFixture(getJunToken);

            await expect(jtb.connect(owner).tokenTransfer(owner.address, dev.address, BigNumber.from("1000"))).to.emit(jtb, "Transfer");
            expect(await jtb.balanceOf(dev.address)).to.equal(BigNumber.from("1000"));
            expect(await jtb.balanceOf(owner.address)).to.equal(BigNumber.from("100000").sub(BigNumber.from("1000")));
        });

        it('transfer to zero address', async function () {
            const { owner, jtb } = await loadFixture(getJunToken);

            await expect(jtb.connect(owner).tokenTransfer(owner.address, ZEROADDRESS, BigNumber.from("100000"))).to.emit(jtb, "Burn");
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
});