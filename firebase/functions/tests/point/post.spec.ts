import "mocha";
import { expect } from "chai";

import { EventName, Point, randomPoint } from "../../src/classes/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

const uid = "user-" + Utils.getTimestamp();
describe("Post point test", () => {
  it("Post create event test - uid: " + uid, async () => {
    // Get my point first,
    const startingPoint = await Point.getUserPoint(uid);

    console.log("startingPoint; ", startingPoint);

    // Make the time check to 3 seconds.
    randomPoint[EventName.postCreate].within = 3;

    const postId = "post-id-" + Utils.getTimestamp();

    // 1. Generage random point for post create
    // 2. Check point change
    // 3. assert point change. data.point is the amount of generated point.
    const ref = await Point.postCreatePoint({ uid: uid }, { params: { postId: postId } });
    expect(ref).not.to.be.null;
    const data = (await ref!.get()).val();
    const pointAfterCreate = await Point.getUserPoint(uid);
    expect(startingPoint + data.point === pointAfterCreate).true;

    // After 4 seconds.
    await Utils.delay(4000);

    // Expect failure.
    // Test with same post id. it will not change point. since it is going to be an update.
    const updateRef = await Point.postCreatePoint({ uid: uid }, { params: { postId: postId } });
    expect(updateRef).to.be.null;

    // Expect success.
    // There will be two point event histories.
    // Do point event for post create with different post id.
    const ref2 = await Point.postCreatePoint({ uid: uid }, { params: { postId: postId + "2" } });
    expect(ref2).not.to.be.null;
    const data2 = (await ref2!.get()).val();
    const pointAfterCreate2 = await Point.getUserPoint(uid);
    expect(startingPoint + data.point + data2.point === pointAfterCreate2).true;

    // Expect failure.
    // After 1.5 seconds later, do it again and expect failure since `within` time has not passed.
    await Utils.delay(1500);
    const ref3 = await Point.postCreatePoint({ uid: uid }, { params: { postId: postId + "3" } });
    expect(ref3 === null).true;
    const pointAfterCreate3 = await Point.getUserPoint(uid);
    console.log(startingPoint + data.point + data2.point + " === " + pointAfterCreate3);
    expect(startingPoint + data.point + data2.point === pointAfterCreate3).true;
  });
});
