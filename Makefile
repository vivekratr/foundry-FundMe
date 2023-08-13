-include .env

build:; forge build

deploy-sapolia:;
	forge script ./script/FundMeScript.s.sol:FundMeDeploy --rpc-url $(SAPOLIA_RPC) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv