#!/usr/bin/env bash

set -eo pipefail

chain=ethereum
c3=0x0000000000C76fe1798a428F60b27c6724e03408
deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec

deploy() {
  local addr=${1:?}
  local salt=${2:?}
  local bytecode=${3:?}
  expect_addr=$(seth call $c3 "deploy(bytes32,bytes)(address)" $salt $bytecode --chain $chain)

  if [[ $(seth --to-checksum-address "${addr}") == $(seth --to-checksum-address "${expect_addr}") ]]; then
    (set -x; seth send $c3 "deploy(bytes32,bytes)" $salt $bytecode --chain $chain)
  else
    echo "Unexpected address."
  fi
}

addr=
salt=
bytecode=0x$(jq -r ".contracts[\"src/WxRING.sol\"].WxRING.evm.bytecode.object" out/dapp.sol.json)

deploy $addr $salt $bytecode
