import "mocha";
import { expect } from "chai";

import { Point } from "../../src/library/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Ref } from "../../src/library/ref";
import { Utils } from "../../src/library/utils";

new FirebaseAppInitializer();

describe("Register point test", () => {
  it("Register point event test", async () => {
    const uid = "point-a" + Utils.getTimestamp();
    // Do random point.
    const ref = await Point.registerPoint({}, { params: { uid: uid } });
    expect(ref).not.to.be.null;
    const data = (await ref!.get()).val();

    // Check if success by getting the real doc data.
    const pointDoc = await Ref.pointRegister(uid).get();
    const registerPointDocData = pointDoc.val();

    expect(data.timestamp).equals(registerPointDocData.timestamp);

    // Do random point again and see if it fails.
    const re = await Point.registerPoint({}, { params: { uid: uid } });
    expect(re).to.be.null;
  });
});
