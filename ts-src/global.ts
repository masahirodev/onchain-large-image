import dotenv from "dotenv";

/**
 * Get .env
 */
dotenv.config();

export const PROVIDER_URL = process.env.PROVIDER_URL!!;
export const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS!!;
export const PRIVATE_KEY = process.env.PRIVATE_KEY!!;
export const ANVIL_PRIVATE_KEY = process.env.ANVIL_PRIVATE_KEY!!;

export const GAS_LIMIT = process.env.GAS_LIMIT ?? "21000";
export const MAX_PRIORITY_FEE_PER_GAS =
  process.env.MAX_PRIORITY_FEE_PER_GAS ?? "5";
export const MAX_FEE_PER_GAS = process.env.MAX_FEE_PER_GAS ?? "20";
export const CHAIN_ID = process.env.CHAIN_ID ?? "31337";

/**
 * ARBIGOERLI
 */
export const ARBIGOERLI_PROVIDER_URL = process.env.ARBIGOERLI_PROVIDER_URL!!;

/**
 * chain list
 */
export const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL!!;
