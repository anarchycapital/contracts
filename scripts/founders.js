// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  const Founders = await hre.ethers.getContractFactory("AcapzFoundersWallet");

  try {
    /* hre.ethernalResetOnStart = true;
    hre.ethernalUploadAst = true;
    hre.ethernalTrace = true;
    hre.ethernalSync = true;

    await hre.ethernal.resetWorkspace("akapz"); */

    const founders = await Founders.deploy(
      "0xc956BbcA545e0071Edcd14AE0531F7fa94D33771",
      "akapz",
      "0.1.0"
    );

    console.log("deployed to: ", founders.address);
  } catch (err) {
    console.error(err);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
