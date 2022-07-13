import { openSync, closeSync, appendFileSync, existsSync, mkdirSync, StatsBase } from "fs";

export const dateFormate = async function() {
    const currentDateTime: number = Date.parse(new Date().toString());
    return currentDateTime;
}
