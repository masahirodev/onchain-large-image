import { Contract, TransactionReceipt, ethers } from "ethers";
import { writeTxProps } from "./wrapInitWriteContract";
import { CONTRACT_ADDRESS, PRIVATE_KEY, PROVIDER_URL } from "../global";

export const writeContract = async ({
  funcName,
  funcAbi,
  funcArg,
}: writeTxProps) => {
  const providerURL = PROVIDER_URL;
  const privateKey = PRIVATE_KEY;
  const provider = new ethers.JsonRpcProvider(providerURL);

  const wallet = new ethers.Wallet(privateKey, provider);

  const signer = wallet.connect(provider);

  const abi = funcAbi;
  const iface = new ethers.Interface(abi);

  // Create a contract
  const contract = new Contract(CONTRACT_ADDRESS, iface, signer);

  try {
    // Send the transaction
    const tx = await contract[funcName](...funcArg!);

    // ...wait for the transaction to be included.
    const receipt: TransactionReceipt = await tx.wait();
    return receipt.hash;
  } catch {
    throw new Error();
  }
};
