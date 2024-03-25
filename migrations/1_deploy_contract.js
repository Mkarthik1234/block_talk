const main = artifacts.require("Chat")
module.exports = function(deployer){
  deployer.deploy(main);
};