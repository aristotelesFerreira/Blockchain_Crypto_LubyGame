var NewNFT = artifacts.require("NewNFT");

module.exports = function (deployer) {
  deployer.deploy(NewNFT);
};

// 1_initial_migration
// const Migrations = artifacts.require("Migrations");

// module.exports = function (deployer) {
//   deployer.deploy(Migrations);
// };
