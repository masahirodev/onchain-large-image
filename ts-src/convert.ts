import fs from "fs";
import path from "path";
import { promisify } from "util";
import { encode } from "base64-arraybuffer";

const readdirAsync = promisify(fs.readdir);
const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);

async function splitAndSaveFile(
  data: string,
  chunkSize: number,
  outputFilePath: string
): Promise<void> {
  try {
    const totalChunks = Math.ceil(data.length / chunkSize);
    const chunks = new Array(totalChunks);

    for (
      let i = 0, byteOffset = 0;
      i < totalChunks;
      i++, byteOffset += chunkSize
    ) {
      const chunk = data.slice(byteOffset, byteOffset + chunkSize);
      chunks[i] = chunk;
    }

    await Promise.all(
      chunks.map(async (chunk, index) => {
        const chunkFilePath = `${outputFilePath}${index}`;
        await writeFileAsync(chunkFilePath, chunk, "utf8");
        console.log(`Saved chunk ${index} to ${chunkFilePath}`);
      })
    );

    console.log(`File split into ${totalChunks} chunks.`);
  } catch (error) {
    console.error("Error:", error);
  }
}

async function convertFilesToBase64(
  inputFolderPath: string,
  outputFolderPath: string,
  chunkSize: number
): Promise<void> {
  try {
    const files = await readdirAsync(inputFolderPath);

    for (const file of files) {
      const filePath = path.join(inputFolderPath, file);
      const fileData = await readFileAsync(filePath);
      const base64Data = encode(fileData);

      await splitAndSaveFile(
        base64Data,
        chunkSize,
        path.join(outputFolderPath, file)
      );

      // writeFileAsync(outputFolderPath + "/balk", base64Data, "utf8");
    }
  } catch (error) {
    console.error("Error:", error);
  }
}

const inputFolderPath = path.join(__dirname, "../image/input");
const outputFolderPath = path.join(__dirname, "../image/output");

// ファイルを分割する際のチャンクサイズ（24,576バイト）
const chunkSize = 24575;

convertFilesToBase64(inputFolderPath, outputFolderPath, chunkSize);
