var Blockopoly = artifacts.require("LubyGame");
// var Blockopoly = artifacts.require("Blockopoly");

module.exports = function (deployer) {
  deployer.deploy(Blockopoly);
};

// 1_initial_migration
// const Migrations = artifacts.require("Migrations");

// module.exports = function (deployer) {
//   deployer.deploy(Migrations);
// };
