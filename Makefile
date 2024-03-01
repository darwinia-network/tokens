all    :; dapp build
flat   :; dapp flat
clean  :; dapp clean

test   :; forge test
salt   :; @create3 -s 00000000000000

deploy-xring   :; dapp create src/XRING.sol:XRING
deploy-lockbox :; @bash ./bin/deploy.sh

.PHONY: all flat clean test salt deploy
