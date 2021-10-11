const fs = require("fs");

// TODO: Set gas price. There are issues if the transaction has not been mined yet

async function main() {
	const [deployer] = await ethers.getSigners();
	console.log(`Deploying contracts with the account: ${deployer.address}`);

	const balance = await deployer.getBalance();
	console.log(`Account balance: ${balance.toString()}`);

	const Contract = await ethers.getContractFactory("NFTShopify");

	// ?: Need to change this
	const contract = await Contract.deploy(
		"https://nft-shopify.vercel.app/api/token/",
		"https://nft-shopify.vercel.app/api/contract"
	);
	console.log(`Contract address: ${contract.address}`);

	const data = {
		address: contract.address,
		abi: JSON.parse(contract.interface.format("json")),
	};

	fs.writeFileSync("frontend/contractData/NFTShopify.json", JSON.stringify(data));
}

main()
	.then(() => process.exit(0))
	.catch(error => {
		console.error(error);
		process.exit(1);
	});
