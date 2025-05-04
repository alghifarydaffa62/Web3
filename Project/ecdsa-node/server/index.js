const express = require("express");
const app = express();
const cors = require("cors");
const secp = require('ethereum-cryptography/secp256k1')
const { toHex, utf8ToBytes } = require('ethereum-cryptography/utils')
const { keccak256 } = require('ethereum-cryptography/keccak')
const port = 3042;

app.use(cors());
app.use(express.json());

const balances = {
  "84a9c9086e0a4c4ed6620f78738e83dd40b6bcee": 100,
  "aad009365d85b6c21c41cd537e4120b3e52e0fed": 50,
  "f0248f3f59dcc6f4ba5dd60dbebfe792ee9119d2": 75,
};

app.get("/balance/:address", (req, res) => {
  const { address } = req.params;
  const balance = balances[address] || 0;
  res.send({ balance });
});

app.post("/send", async (req, res) => {
  const { sender, recipient, amount, message, signature } = req.body;

  const messageHash = keccak256(utf8ToBytes(message));

  try {
    const signatureBytes = new Uint8Array([
      ...Buffer.from(signature.r, "hex"),
      ...Buffer.from(signature.s, "hex"),
    ]);

    const publicKey = secp.secp256k1.recoverPublicKey(messageHash, signatureBytes);
    const recoveredAddress = toHex(keccak256(publicKey.slice(1)).slice(-20));

    if (recoveredAddress !== sender) {
      return res.status(400).send({ message: "Invalid signature!" });
    }

    if (!balances[sender] || balances[sender] < amount) {
      return res.status(400).send({ message: "Not enough funds!" });
    }

    setInitialBalance(recipient);

    balances[sender] -= amount;
    balances[recipient] += amount;
    res.send({ balance: balances[sender] });
  } catch (err) {
    console.error(err);
    res.status(400).send({ message: "Error verifying signature" });
  }
});

app.listen(port, () => {
  console.log(`Listening on port ${port}!`);
});

function setInitialBalance(address) {
  if (!balances[address]) {
    balances[address] = 0;
  }
}
