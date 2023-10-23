import * as fs from "fs";

export async function getFilesInFolder(folderPath: string): Promise<string[]> {
  return new Promise<string[]>((resolve, reject) => {
    fs.readdir(folderPath, (err, files) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(files);
    });
  });
}
