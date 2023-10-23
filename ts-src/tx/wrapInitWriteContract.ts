import { writeContract } from "./writeContract";

export type ReadTxProps = {
  funcName: string;
  funcAbi: any[];
  funcArg?: any[];
  contractAddress?: string;
};

export type writeTxProps = {
  txArg: {
    from?: string;
    gasLimit?: number;
    maxPriorityFeePerGas?: number;
    maxFeePerGas?: number;
    value?: number;
    chainId?: number;
  };
} & ReadTxProps;

export const wrapInitWriteContract = async (
  init: Omit<writeTxProps, "funcName">,
  funcName: string,
  funcArg?: any[]
) => {
  const txProps = {
    ...init,
    funcName: funcName,
    funcArg: funcArg,
  };

  return await writeContract(txProps);
};
