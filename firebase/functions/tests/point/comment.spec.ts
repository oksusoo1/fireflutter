import "mocha";
import { expect } from "chai";

import { EventName, Point, randomPoint } from "../../src/classes/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";
import { Comment } from "../../src/classes/comment";
import { User } from "../../src/classes/user";

new FirebaseAppInitializer();

const uid = "user-" + Utils.getTimestamp();
describe("Comment point test", () => {
  it("Comment create event test - uid: " + uid, async () => {
    await User.create(uid, {
      firstName: "fn",
    });
    await User.get(uid);

    // wait sometime for register and get's register bonus.
    await Utils.delay(2000);

    // Get my point first,
    const startingPoint = await Point.getUserPoint(uid);

    // console.log("startingPoint; ", startingPoint);

    // console.log("startingPoint; ", startingPoint);

    // Make the time check to 3 seconds.
    randomPoint[EventName.commentCreate].within = 3;

    // console.log(lib.randomPoint);

    const doc = await Comment.create({ postId: "post-id-1-c", uid: "uid1" });
    const commentId = doc!.id;

    // 1. Generage random point for comment create
    // 2. Check point change
    // 3. assert point change. data.point is the amount of generated point.
    const ref = await Point.commentCreatePoint({ uid: uid }, { params: { commentId: commentId } });
    expect(ref).not.to.be.null;
    const data = (await ref!.get()).val();
    const pointAfterCreate = await Point.getUserPoint(uid);
    // console.log("pointAfterCreate; ", pointAfterCreate);
    expect(startingPoint + data.point === pointAfterCreate).true;

    // check if the comment doc has point.
    const comment = await Comment.get(commentId);
    expect(data.point === comment!.point);

    // Delay 4 seconds for bonus point event generated
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

    const doc2 = await Comment.create({ postId: "post-id-2-c", uid: "uid1" });
    const commentId2 = doc2!.id;

    const ref2 = await Point.commentCreatePoint(
        { uid: uid },
        { params: { commentId: commentId2 } }
    );

    expect(ref2).not.to.be.null;
    const data2 = (await ref2!.get()).val();
    const point2 = await Point.getUserPoint(uid);

    // console.log(startingPoint, data.point);
    // console.log(point2);

    expect(startingPoint + data.point + data2.point === point2).true;

    // Expect failure.
    // After 1.5 seconds later, do it again and expect failure since `within` time has not passed.
    await Utils.delay(1500);

    const doc3 = await Comment.create({ postId: "post-id-2-c", uid: "uid1" });
    const commentId3 = doc3!.id;
    const ref3 = await Point.commentCreatePoint(
        { uid: uid },
        { params: { commentId: commentId3 } }
    );
    // `within` limited time didn't passed, so, there will be no point changes.
    expect(ref3 === null).true;

    const comment3 = await Comment.get(commentId3);
    expect(data.point === comment3!.point);

    const pointAfterCreate3 = await Point.getUserPoint(uid);
    console.log("point after create 3 ", pointAfterCreate3);
    // console.log(startingPoint + comment!.point + (data2.point ?? 0) + (comment3!.point ?? 0));
    expect(
        startingPoint + comment!.point + (data2.point ?? 0) + (comment3!.point ?? 0) ===
        pointAfterCreate3
    ).true;

    // const user = await User.get(uid);
    // expect(user!.point).equal(pointAfterCreate3);
  });
});
