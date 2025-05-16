const axios = require('axios');

const ALCHEMY_URL = "https://eth-mainnet.g.alchemy.com/v2/rCrDSzBlwrg0IXnT_HrD_kbFHwJ-BOhb";

axios.post(ALCHEMY_URL, {
  jsonrpc: "2.0",
  id: 1,
  method: "eth_getBlockByNumber",
  params: [
    "0xb443", 
    true  
  ]
}).then((response) => {
  console.log(response.data.result);
});