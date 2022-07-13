import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
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
            await jtb.connect(owner).sendToken(dev.address, BigNumber.from("10000"));
            expect(await jtb.balanceOf(owner.address)).to.equal(BigNumber.from("100000").sub(BigNumber.from("10000")));
            expect(await jtb.userBalance(owner.address)).to.equal(BigNumber.from("100000").sub(BigNumber.from("10000")));
            expect(await jtb.balanceOf(dev.address)).to.equal(BigNumber.from("10000"));
            expect(await jtb.userBalance(dev.address)).to.equal(BigNumber.from("10000"));
        });

        it('transfer to dev', async function () {
            const { owner, dev, jtb } = await loadFixture(getJunToken);

            await expect(jtb.connect(owner).tokenTransfer(owner.address, dev.address, BigNumber.from("1000"))).to.emit(jtb, "Transfer");
            expect(await jtb.balanceOf(dev.address)).to.equal(BigNumber.from("1000"));
            expect(await jtb.balanceOf(owner.address)).to.equal(BigNumber.from("100000").sub(BigNumber.from("1000")));
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
    })
});