#!/usr/bin/env bash

set -eo pipefail

c3=0x0000000000C76fe1798a428F60b27c6724e03408

ring=0x9469D013805bFfB7D3DEBe5E7839237e535ec483
xring=0x4941f719fb5775edbebdcfb632b10b9f87fc16eb

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

addr=0x0000000001Bda3C76095859d7C711B083F621C12
salt=0x5652a031f6e72e750ac230040e03104a00098859a4a26642de03131ae191f6b6
bytecode=$(jq -r ".contracts[\"src/XRINGLockBox.sol\"].XRINGLockBox.evm.bytecode.object" out/dapp.sol.json)
args=$(set -x; ethabi encode params \
  -v address "${ring:2}" \
  -v address "${xring:2}"
)
creationCode=0x$bytecode$args

deploy $addr $salt $creationCode

dapp verify-contract src/XRINGLockBox.sol:XRINGLockBox $addr $ring $xring
