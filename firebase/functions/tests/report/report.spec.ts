import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Report } from "../../src/classes/report";

new FirebaseAppInitializer();

describe("Report test", () => {
  it("Report create", async () => {
    const re = await Report.create({
      uid: "",
      target: "comment",
      targetId: "...",
      reporteeUid: "..",
      reason: "..",
    });
    expect(re).to.be.an("object");
  });
});
