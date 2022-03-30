import "mocha";
import { expect } from "chai";

import { Point } from "../../src/lib/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

new FirebaseAppInitializer();

describe("Sign-in point test", () => {
  it("sign-in point test", async () => {
    const uid = "point-a";
    const startingPoint = await Point.getUserPoint(uid);
    expect(startingPoint).to.be.an("number");
    await Point.signInPoint({ after: { lastLogin: 1234 } }, { params: { uid: uid } });
    const updatedPoint = await Point.getUserPoint(uid);
    expect(updatedPoint).to.be.an("number");
    console.log("updatedPoint; ", updatedPoint);
  });
});
