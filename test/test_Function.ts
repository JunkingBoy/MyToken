import { dateFormate } from "../src/tools/FormateOutPut";

describe("test", function () {
    it('test', async function () {
        let currentTimeStamp = dateFormate();
        console.log(currentTimeStamp);
    });
});