import "mocha";
import { expect } from "chai";

import { EventName, Point, randomPoint } from "../../src/classes/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

describe("Sign-in point test", () => {
  it("sign-in point success test", async () => {
    const uid = "point-a";
    // Get current point.
    const startingPoint = await Point.getUserPoint(uid);
    expect(startingPoint).to.be.an("number", `startingPoint: ${startingPoint}`);

    // Set `within` 3 seconds and wait for 3 seconds
    randomPoint[EventName.signIn].within = 3;
    await Utils.delay(3000);

    // Update.
    const ref = await Point.signInPoint({ after: {} }, { params: { uid: uid } });

    // expect success
    expect(ref).not.to.be.null;

    // get bonus point
    const snapshot = await ref!.get();
    const data = snapshot.val();

    // get current point(after update).
    const updatedPoint = await Point.getUserPoint(uid);

    // check `starting point + bonus point = updated point`
    expect(startingPoint + data.point).equal(
      updatedPoint,
      `startingPoint:${startingPoint} vs updatedPoint:${updatedPoint}`
    );
  });

  it("sign-in point fail test", async () => {
    const uid = "point-a";
    // Get current point.
    const startingPoint = await Point.getUserPoint(uid);
    expect(startingPoint).to.be.an("number", `startingPoint: ${startingPoint}`);

    // Update.
    const ref = await Point.signInPoint({ after: {} }, { params: { uid: uid } });

    // expect success
    expect(ref).to.be.null;
  });
});
