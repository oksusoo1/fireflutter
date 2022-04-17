import "mocha";
import { expect } from "chai";

import { EventName, Point, randomPoint } from "../../src/classes/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";
import { Post } from "../../src/classes/post";
// import { User } from "../../src/classes/user";
import { Test } from "../../src/classes/test";
import { User } from "../../src/classes/user";
import { Category } from "../../src/classes/category";

new FirebaseAppInitializer();

// const uid = "user-" + Utils.getTimestamp();
describe("Post point test", () => {
  it("Post create point event", async () => {
    // Create user
    const user = await Test.createUser();

    // Wait sometime for register and get's register bonus.
    await Utils.delay(2000);

    // Get current user point
    const startingPoint = await Point.getUserPoint(user.id);

    // Make the time limit of post create to 3 seconds.
    randomPoint[EventName.postCreate].within = 3;

    // Create category
    const category = await Test.createCategory();

    // 1st post create
    const post = await Post.create({ category: category.id, uid: user.id });
    expect(post).to.be.an("object");

    const pointAfterCreate = await Point.getUserPoint(user.id);

    // register point + post create point == point after post create
    expect(startingPoint + post.point! === pointAfterCreate).true;

    // 2nd post create test

    // After 4 seconds. for the within time limit.
    await Utils.delay(4000);

    // create 2nd post and compare point
    const post2 = await Post.create({ category: category.id, uid: user.id });
    expect(post2).to.be.an("object");

    const pointAfterCreate2 = await Point.getUserPoint(user.id);
    console.log(
        `expect(${startingPoint} + ${post.point!} + ${post2.point!} === ${pointAfterCreate2}).true;`
    );

    expect(startingPoint + post.point! + post2.point! === pointAfterCreate2).true;

    // 3rd post create
    // Expect failure.
    // After 1 seconds later, do it again and expect failure since `within` time has not passed.
    await Utils.delay(1000);
    const post3 = await Post.create({ category: category.id, uid: user.id });
    expect(post3).to.be.an("object").not.to.have.property("point");
    const pointAfterCreate3 = await Point.getUserPoint(user.id);
    expect(startingPoint + post.point! + post2.point! + (post3.point ?? 0) === pointAfterCreate3)
        .true;

    const u = await User.get(user.id);
    if (u!.point < 1000) expect(u!.level).equals(1);
    else if (u!.point < 3000) expect(u!.level).equals(2);
    else if (u!.point < 6000) expect(u!.level).equals(3);
  });
  it("Post create - with category point setting", async () => {
    // Create user
    const user = await Test.createUser();

    // Wait sometime for register and get's register bonus.
    await Utils.delay(2000);

    // Get current user point
    const startingPoint = await Point.getUserPoint(user.id);

    // Create category with point 12345
    const category = await Category.create({
      id: "cat-point-id" + Utils.getTimestamp(),
      point: 12345,
    });
    expect(category).not.to.be.null;

    // create post
    const post = await Post.create({ category: category!.id, uid: user.id });
    expect(post).to.be.an("object").to.have.property("point").equals(12345);
    const pointAfterCreate = await Point.getUserPoint(user.id);
    expect(startingPoint + post.point!).equals(pointAfterCreate);

    // Create category with -345
    const category2 = await Category.create({
      id: "cat-point-id" + Utils.getTimestamp(),
      point: -345,
    });
    expect(category2).not.to.be.null;

    console.log(category2);

    // create post
    const post2 = await Post.create({ category: category2!.id, uid: user.id });
    expect(post2).to.be.an("object").to.have.property("point").equals(-345);
    const pointAfterCreate2 = await Point.getUserPoint(user.id);

    console.log(
        `expect(${startingPoint} + ${post.point!} + ${post2.point!}).equals(${pointAfterCreate2});`
    );
    expect(startingPoint + post.point! + post2.point!).equals(pointAfterCreate2);
  });
});
