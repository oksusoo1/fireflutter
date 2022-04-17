import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";
import { Category } from "../../src/classes/category";

new FirebaseAppInitializer();

describe("Category test", () => {
  it("Category test", async () => {
    const id = "cat-test-" + Utils.getTimestamp();
    const cat = await Category.create({ id: id, point: 0 });
    console.log(cat);
    expect(cat).to.be.an("object");
  });
});
