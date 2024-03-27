#!/usr/bin/env bash

set -eo pipefail

c3=0x0000000000C76fe1798a428F60b27c6724e03408

# ring=0x9469D013805bFfB7D3DEBe5E7839237e535ec483
ring=0xdE64c6d8b24eeB16D864841d2873aB7a379c45b6
xring=0x3beb2cf5c2c050bc575350671aa5f06e589386e8

deploy() {
  local addr=${1:?}
  local salt=${2:?}
  local bytecode=${3:?}
  expect_addr=$(seth call $c3 "deploy(bytes32,bytes)(address)" $salt $bytecode)

  if [[ $(seth --to-checksum-address "${addr}") == $(seth --to-checksum-address "${expect_addr}") ]]; then
    (set -x; seth send $c3 "deploy(bytes32,bytes)" $salt $bytecode)
  else
    echo "Unexpected address."
    exit 1
  fi
}

# addr=0x00000000062D35A6F9F82305c47A786527896578
# salt=0x1915aa6cca3e70208936e97247fc18f47e28dcba247dd04dc3950953297b5b92
addr=0x00002C6B069D1dA278730aFD3C9DC4CEDcfe7Ebc
salt=0xf5c714df684b617e2fe8924c79a3b8da7377f516932860476f54576486f257ce
bytecode=$(jq -r ".contracts[\"src/XRINGLockBox.sol\"].XRINGLockBox.evm.bytecode.object" out/dapp.sol.json)
args=$(set -x; ethabi encode params \
  -v address "${ring:2}" \
  -v address "${xring:2}"
)
creationCode=0x$bytecode$args

deploy $addr $salt $creationCode

dapp verify-contract src/XRINGLockBox.sol:XRINGLockBox $addr $ring $xring
