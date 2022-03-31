import "mocha";
import { expect } from "chai";

import { EventName, Point, randomPoint } from "../../src/library/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/library/utils";

new FirebaseAppInitializer();

const uid = "user-" + Utils.getTimestamp();
describe("Post point test", () => {
  it("Comment create event test - uid: " + uid, async () => {
    // Get my point first,
    const startingPoint = await Point.getUserPoint(uid);

    // console.log("startingPoint; ", startingPoint);

    // Make the time check to 3 seconds.
    randomPoint[EventName.commentCreate].within = 3;

    // console.log(lib.randomPoint);

    const commentId = "comment-id-" + Utils.getTimestamp();

    // 1. Generage random point for comment create
    // 2. Check point change
    // 3. assert point change. data.point is the amount of generated point.
    const ref = await Point.commentCreatePoint({ uid: uid }, { params: { commentId: commentId } });
    expect(ref).not.to.be.null;
    const data = (await ref!.get()).val();
    const pointAfterCreate = await Point.getUserPoint(uid);
    expect(startingPoint + data.point === pointAfterCreate).true;

    // After 4 seconds.
    await Utils.delay(4000);

    // Expect failure.
    // Test with same comment id. it will not change point. since it is going to be an update.
    const updateRef = await Point.commentCreatePoint(
      { uid: uid },
      { params: { commentId: commentId } }
    );
    expect(updateRef === null).true;

    // Expect success.
    // There will be two point event histories.
    // Do point event for comment create with different comment id.
    const ref2 = await Point.commentCreatePoint(
      { uid: uid },
      { params: { commentId: commentId + "2" } }
    );
    expect(ref2).not.to.be.null;
    const data2 = (await ref2!.get()).val();
    const pointAfterCreate2 = await Point.getUserPoint(uid);
    expect(startingPoint + data.point + data2.point === pointAfterCreate2).true;

    // Expect failure.
    // After 1.5 seconds later, do it again and expect failure since `within` time has not passed.
    await Utils.delay(1500);
    const ref3 = await Point.commentCreatePoint(
      { uid: uid },
      { params: { commentId: commentId + "3" } }
    );
    expect(ref3 === null).true;
    const pointAfterCreate3 = await Point.getUserPoint(uid);
    expect(startingPoint + data.point + data2.point === pointAfterCreate3).true;
  });
});
