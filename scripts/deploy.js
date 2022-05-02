// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

const params = require("./params").params;

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  const AkapzToken = await ethers.getContractFactory("AkapzToken");
  try {
    /* hre.ethernalResetOnStart = true;
    hre.ethernalUploadAst = true;
    hre.ethernalTrace = true;
    hre.ethernalSync = true;

    await hre.ethernal.resetWorkspace("akapz"); */

    const akapzToken = await upgrades.deployProxy(
      AkapzToken,
      [
        params.token.name,
        params.token.symbol,
        params.token.initialSupply,
        params.token.owner,
        params.token.cap,
      ],
      {
        initializer: "initialize",
      }
    );

    await akapzToken.deployed();

    const Staking = await ethers.getContractFactory("StakingToken");
    const StakingToken = await upgrades.deployProxy(
        Staking,
        ["Akapz Staking Token", "AKST", 1000000],
        {
       kind:"uups"}
    );

    await StakingToken.deployed();



    console.log("deployed to: ", akapzToken.address);
    console.log("staking address: ", StakingToken.address);
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
