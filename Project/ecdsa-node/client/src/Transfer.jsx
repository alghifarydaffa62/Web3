import { useState } from "react";
import { keccak256 } from 'ethereum-cryptography/keccak'
import { utf8ToBytes, toHex } from "ethereum-cryptography/utils"
import * as secp from 'ethereum-cryptography/secp256k1'
import server from "./server";

function Transfer({ address, setBalance}) {
  const [sendAmount, setSendAmount] = useState("");
  const [recipient, setRecipient] = useState("");
  const [privateKey, setPrivateKey] = useState("");

  const setValue = (setter) => (evt) => setter(evt.target.value);

  async function transfer(evt) {
    evt.preventDefault();
    const message = `${address}:${recipient}:${sendAmount}`;
    const messageBytes = utf8ToBytes(message);
    const messageHash = keccak256(messageBytes);

    const [signature, recoveryBit] = secp.secp256k1.sign(messageHash, privateKey, {recovered: true});
    
    try {
      const {
        data: { balance },
      } = await server.post(`send`, {
        sender: address,
        amount: parseInt(sendAmount),
        recipient,
        signature: {
          r: toHex(signature.slice(0, 32)),
          s: toHex(signature.slice(32, 64)),
          recovery: recoveryBit
        },
      });
      setBalance(balance);
    } catch (ex) {
      // alert(ex.response.data.message);
      alert(ex.response?.data?.message || "Transaction failed");
    }
  }

  return (
    <form className="container transfer" onSubmit={transfer}>
      <h1>Send Transaction</h1>

      <label>
       Private key
        <input
          placeholder="Your private key"
          value={privateKey}
          onChange={setValue(setPrivateKey)}
        ></input>
      </label>

      <label>
        Send Amount
        <input
          placeholder="1, 2, 3..."
          value={sendAmount}
          onChange={setValue(setSendAmount)}
        ></input>
      </label>

      <label>
        Recipient
        <input
          placeholder="Type an address, for example: 0x2"
          value={recipient}
          onChange={setValue(setRecipient)}
        ></input>
      </label>

      <input type="submit" className="button" value="Transfer" />
    </form>
  );
}

export default Transfer;
