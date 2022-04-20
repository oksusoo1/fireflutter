import "mocha";
import { expect } from "chai";

import { Point, randomPoint } from "../../src/classes/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";
import { Comment } from "../../src/classes/comment";
// import { User } from "../../src/classes/user";
import { Test } from "../../src/classes/test";
import { User } from "../../src/classes/user";
import { EventName } from "../../src/interfaces/point.interface";

new FirebaseAppInitializer();

// const uid = "user-" + Utils.getTimestamp();
describe("Comment point test", () => {
  it("Comment create event", async () => {
    const user = await Test.createUser();

    // wait sometime for register and get's register bonus.
    await Utils.delay(2000);

    // Get my point first,
    const startingPoint = await Point.getUserPoint(user.id);

    // Make the time check to 3 seconds.
    randomPoint[EventName.commentCreate].within = 3;

    // 1st comment
    const comment = await Comment.create({ postId: "post-id-1-c", uid: user.id });
    const pointAfterCreate = await Point.getUserPoint(user.id);
    expect(startingPoint + comment.point === pointAfterCreate).true;

    // 2nd comment

    // Delay 4 seconds for bonus point event generated
    await Utils.delay(4000);

    // Expect success.
    // There will be two point event histories.
    // Do point event for comment create with different comment id.

    const comment2 = await Comment.create({ postId: "post-id-2-c", uid: user.id });
    const pointAfterCreate2 = await Point.getUserPoint(user.id);
    expect(startingPoint + comment.point + comment2.point === pointAfterCreate2).true;

    // 3rd comment. Expect failure.
    // After 1.5 seconds later, do it again and expect failure since `within` time has not passed.
    await Utils.delay(1500);

    const comment3 = await Comment.create({ postId: "post-id-2-c", uid: user.id });
    const pointAfterCreate3 = await Point.getUserPoint(user.id);
    expect(
        startingPoint + comment.point! + comment2.point! + (comment3.point ?? 0) === pointAfterCreate3
    ).true;

    const u = await User.get(user.id);
    if (u!.point < 1000) expect(u!.level).equals(1);
    else if (u!.point < 3000) expect(u!.level).equals(2);
    else if (u!.point < 6000) expect(u!.level).equals(3);
  });
});
