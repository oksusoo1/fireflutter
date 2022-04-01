import "mocha";
import { expect } from "chai";

import { Point } from "../../src/classes/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Ref } from "../../src/classes/ref";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";

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
  it("Register test via database", async () => {
    const uid = "user-" + Utils.getTimestamp();
    await User.create(uid, {
      firstName: "fn",
    });
    // wait sometime for register and get's register bonus.
    await Utils.delay(2000);

    const point = await Point.getUserPoint(uid);

    const user = await User.get(uid);
    console.log(user);
    expect(user!.point).equal(point);
  });
});
