import "mocha";
import { expect } from "chai";

import { EventName, Point, randomPoint } from "../../src/classes/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";
import { Post } from "../../src/classes/post";
import { User } from "../../src/classes/user";

new FirebaseAppInitializer();

const uid = "user-" + Utils.getTimestamp();
describe("Post point test", () => {
  it("Post create event test - uid: " + uid, async () => {
    await User.create(uid, {
      firstName: "fn",
    });
    await User.get(uid);

    // wait sometime for register and get's register bonus.
    await Utils.delay(2000);

    // Get my point first,
    const startingPoint = await Point.getUserPoint(uid);

    // console.log("startingPoint; ", startingPoint);

    // Make the time check to 3 seconds.
    randomPoint[EventName.postCreate].within = 3;

    const doc = await Post.create({ category: "cat1", uid: "uid1" });
    const postId = doc!.id;

    // 1. Generage random point for post create
    // 2. Check point change
    // 3. assert point change. data.point is the amount of generated point.
    const ref = await Point.postCreatePoint({ uid: uid }, { params: { postId: postId } });
    expect(ref).not.to.be.null;

    // ** Get point fromt the document (not from point history) and compare.
    const post = await Post.get(postId);

    const pointAfterCreate = await Point.getUserPoint(uid);

    expect(startingPoint + post!.point === pointAfterCreate).true;

    // After 4 seconds. for the within time limit.
    await Utils.delay(4000);

    // Expect failure.
    // Test with same post id. it will not change point. since it is going to be an update.
    const updateRef = await Point.postCreatePoint({ uid: uid }, { params: { postId: postId } });
    expect(updateRef).to.be.null;

    // Expect success.
    // There will be two point event histories.
    // Do point event for post create with different post id.
    const doc2 = await Post.create({ category: "cat1", uid: "uid1" });
    const postId2 = doc2!.id;
    const ref2 = await Point.postCreatePoint({ uid: uid }, { params: { postId: postId2 } });
    expect(ref2).not.to.be.null;

    // ** Get point from point event history document and compare.
    const data2 = (await ref2!.get()).val();
    const pointAfterCreate2 = await Point.getUserPoint(uid);
    expect(startingPoint + post!.point + data2!.point === pointAfterCreate2).true;

    // Expect failure.
    // After 1.5 seconds later, do it again and expect failure since `within` time has not passed.
    await Utils.delay(1000);
    const doc3 = await Post.create({ category: "cat1", uid: "uid1" });
    const postId3 = doc3!.id;
    const ref3 = await Point.postCreatePoint({ uid: uid }, { params: { postId: postId3 } });
    expect(ref3 === null).true;
    const pointAfterCreate3 = await Point.getUserPoint(uid);
    // console.log(
    //   startingPoint + post!.point + data2!.point + " === " + pointAfterCreate3,
    //   "postId; ",
    //   postId
    // );
    expect(startingPoint + post!.point + data2!.point === pointAfterCreate3).true;

    const user = await User.get(uid);
    expect(user!.point).equal(pointAfterCreate3);
  });
});
