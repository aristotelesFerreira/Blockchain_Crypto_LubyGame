const Teste = artifacts.require("Teste");

contract("Teste", function (accounts) {
  it("should start an account with 0 coins", async function () {
    const contract = await Teste.deployed();

    const balance = await contract.balanceOf.call(accounts[0]);
    balance.transfer("0xF53879BF892BFe33bb57CA4C1d646d9a460ABE28", 10);
    // function transfer(address receiver, uint256 amount) public {
  });
});
