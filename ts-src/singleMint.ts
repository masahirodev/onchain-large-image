import fs from "fs";
import { getEvents } from "./tx/getEvents";
import { wrapInitWriteContract } from "./tx/wrapInitWriteContract";
import { init } from "./upload";

const mint = async () => {
  const txDataPath = "./image/upload/bundleAddressData.json";
  const dataObject = JSON.parse(fs.readFileSync(txDataPath, "utf8"));
  const dictionary: { [key: string]: string } = dataObject;

  const bundleAddressData = dictionary["bundleAddressData"];

  const txData = [bundleAddressData];
  const tx = await wrapInitWriteContract(init, "safeMint", txData);
  console.log(tx);
};

mint();
