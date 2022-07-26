import { ethers } from "hardhat";
import { BigNumber } from "ethers";

async function main() {
    const FJB = await ethers.getContractFactory("JunToken");
    const fjb = await FJB.deploy("LJB", "LJB", BigNumber.from("10000000000000000000000000"));
    console.log("ljb:\t" + fjb.address);
}

main()
    .then(() => { console.log("deploy successfully!"), process.exitCode = 0 })
    .catch((error) => {
    console.error("deploy fail, message:\t" + error);
    process.exitCode = 1;
});
