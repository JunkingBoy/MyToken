import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      blockGasLimit: 100000000,
      gas: 100000000
    },
    kccTest: {
      url: 'https://rpc-testnet.kcc.network',
      chainId: 322,
      accounts: ['90620ab73552e543d65ca08251e0a60c753bbed07363c99b29b5af5242708028']
      // gasPrice: 20000000000,
      // accounts: {mnemonic: mnemonic}
    }
  },

  solidity: {
    compilers: [
      { version: "0.8.9" }
    ]
  }
};

export default config;
