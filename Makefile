all    :; dapp build
flat   :; dapp flat
clean  :; dapp clean

test   :; forge test
salt   :; @create3 -s 00000000000000 -d 0xa4FA5429544B225985F8438F2E013A9CCE7102f2

deploy-xring   :; dapp create src/XRING.sol:XRING
deploy-lockbox :; @bash ./bin/deploy.sh

.PHONY: all flat clean test salt deploy
