import fs from "fs";
import { getEvents } from "./tx/getEvents";
import { wrapInitWriteContract } from "./tx/wrapInitWriteContract";
import { init } from "./upload";

const txDataPath = "./image/upload/tx.json";
const dataObject = JSON.parse(fs.readFileSync(txDataPath, "utf8"));
const dictionary: { [key: string]: string } = dataObject;
const outputPath = "./image/upload/bundleAddressData.json";

const mint = async () => {
  const d: { [key: string]: string } = {};

  const events = await getEvents();
  events.forEach((event) => {
    d[event.transactionHash] = event.topics[1]; // pointer
  });

  // 結果を格納するオブジェクト
  const resultObject: { [key: string]: string } = {};

  // キーをソート
  const sortedKeys = Object.keys(dictionary).sort((a, b) => {
    const numA = parseInt(a.match(/\d+/)![0]);
    const numB = parseInt(b.match(/\d+/)![0]);
    return numA - numB;
  });

  for (const key of sortedKeys) {
    const value = dictionary[key];
    const address = d[value];
    if (address === undefined) {
      throw new Error(`${key}データが欠落している`);
    }
    resultObject[key] = address;
  }

  const addrs: string[] = Object.values(resultObject);

  const bundleAddressData = addrs
    .map((element, index) =>
      index === 0 ? "0x" + element.slice(26) : element.slice(26)
    )
    .join("");

  const txData = [bundleAddressData];
  const tx = await wrapInitWriteContract(init, "safeMint", txData);
  console.log(tx);

  const jsonData = JSON.stringify({ bundleAddressData: bundleAddressData });
  fs.writeFileSync(outputPath, jsonData, "utf-8");
};

mint();
