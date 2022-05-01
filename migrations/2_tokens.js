// eslint-disable-next-line no-undef
const StakingToken = artifacts.require("StakingToken");

module.exports = function (deployer, accounts) {
  deployer.deploy(StakingToken);
}