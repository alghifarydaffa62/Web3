const secp = require('ethereum-cryptography/secp256k1')
const { toHex } = require('ethereum-cryptography/utils')
const { keccak256 } = require('ethereum-cryptography/keccak')

const privatekey = secp.secp256k1.utils.randomPrivateKey()
console.log('Private key: ', toHex(privatekey))

const publicKey = secp.secp256k1.getPublicKey(privatekey)
console.log('Public key: ', toHex(publicKey))

const address = keccak256(publicKey.slice(1)).slice(-20)
console.log('Address: ', toHex(address))

