import * as fs from "fs";

import deployJson from "../out/OnchainLargeImage.sol/OnchainLargeImage.json";
import { getFilesInFolder } from "./lib/getFilesInFolder";
import {
  wrapInitWriteContract,
  writeTxProps,
} from "./tx/wrapInitWriteContract";

/*
    set config
*/
export const init: Omit<writeTxProps, "funcName"> = {
  funcAbi: deployJson.abi,
  contractAddress: process.env.CONTRACT_ADDRESS!!,
  txArg: { chainId: Number(process.env.CHAIN_ID!!) },
};

const txDataPath = "./image/upload/tx.json";
const dataObject = JSON.parse(fs.readFileSync(txDataPath, "utf8"));
const dictionary: { [key: string]: string } = dataObject;

const folderPath = "./image/output/";
const upload = async () => {
  const files = await getFilesInFolder(folderPath);

  for await (const file of files) {
    const filePath = folderPath + file;
    const textData = fs.readFileSync(filePath, "utf8");

    const txData = [textData];
    try {
      const tx = await wrapInitWriteContract(init, "upload", txData);
      dictionary[file] = tx;
      fs.unlinkSync(filePath); // ファイルを削除
      console.log(`ファイル ${file} を正常にアップロードし、削除しました`);
    } catch (error) {
      console.error(
        `ファイル ${file} のアップロード中にエラーが発生しました:`,
        error
      );
      throw new Error();
    }
  }
};

upload().finally(() => {
  const jsonData = JSON.stringify(dictionary);
  fs.writeFileSync(txDataPath, jsonData, "utf-8");
  console.log(jsonData);
});
