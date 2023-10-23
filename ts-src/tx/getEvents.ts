import { Contract, ethers } from "ethers";
import { CONTRACT_ADDRESS, PROVIDER_URL } from "../global";
import deployJson from "../../out/OnchainLargeImage.sol/OnchainLargeImage.json";

export const getEvents = async () => {
  const providerURL = PROVIDER_URL;
  const provider = new ethers.JsonRpcProvider(providerURL);

  const abi = deployJson.abi;
  const iface = new ethers.Interface(abi);

  // Create a contract
  const contract = new Contract(CONTRACT_ADDRESS, iface, provider);

  const events: ethers.EventLog[] = (await contract.queryFilter(
    "Upload"
  )) as ethers.EventLog[];
  return events;
};
