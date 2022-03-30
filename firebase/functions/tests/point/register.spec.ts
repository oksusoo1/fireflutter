import "mocha";
import { expect } from "chai";

import { EventName, Point, randomPoint } from "../../src/library/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/library/utils";

new FirebaseAppInitializer();

describe("Sign-in point test", () => {
  it("Register point event test", async () => {
    // Do random point.
    const ref = await lib.userRegisterPoint({}, { params: { uid: uid } });
    assert.ok(ref !== null);
    const data = (await ref.get()).val();

    // Check if success by getting the real doc data.
    const pointDoc = await lib.pointRegisterRef(uid).get();
    const pointDocData = pointDoc.val();

    assert.ok(data.timestamp === pointDocData.timestamp);

    // Do random point again and see if it fails.
    const re = await lib.userRegisterPoint({}, { params: { uid: uid } });
    assert.ok(re === null);
  });
});
