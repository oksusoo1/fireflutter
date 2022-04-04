/**
 * @file list.spec.ts
 * @description Generate many point histories and get by monthly
 * see README.md for details.
 */

import "mocha";
import { expect } from "chai";
import * as dayjs from "dayjs";

// import { EventName, Point, randomPoint } from "../../src/classes/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { Utils } from "../../src/classes/utils";
// import { Comment } from "../../src/classes/comment";
// import { User } from "../../src/classes/user";
import { Ref } from "../../src/classes/ref";
import { Utils } from "../../src/classes/utils";
import { Point } from "../../src/classes/point";

new FirebaseAppInitializer();

const uid = "point-list-test-a" + Utils.getTimestamp();

/**
 * Generate test registration bonus point.
 * @param timestamp timestamp
 * @param point set point
 */
async function setRegisterPoint(timestamp: number, point: number) {
  const ref = Ref.pointRegister(uid);
  const docData = { timestamp: timestamp, point: point };
  await ref.set(docData);
}

/**
 * Generate test sign-in bonus point.
 * @param timestamp timestamp
 * @param point set point
 */
async function setSignInPoint(timestamp: number, point: number) {
  const ref = Ref.pointSignIn(uid).push();
  const docData = { timestamp: timestamp, point: point };
  await ref.set(docData);
}
/**
 * Generate test sign-in bonus point.
 * @param timestamp timestamp
 * @param point set point
 */
async function setPostCreatePoint(timestamp: number, point: number) {
  const ref = Ref.pointPostCreate(uid).push();
  const docData = { timestamp: timestamp, point: point };
  await ref.set(docData);
}
/**
 * Generate test sign-in bonus point.
 * @param timestamp timestamp
 * @param point set point
 */
async function setCommentCreatePoint(timestamp: number, point: number) {
  const ref = Ref.pointCommentCreate(uid).push();
  const docData = { timestamp: timestamp, point: point };
  await ref.set(docData);
}

describe("Point history test with: " + uid, () => {
  it("Register only - get histories", async () => {
    // Registration
    const timestamp = dayjs().year(2021).month(11).date(1).unix();
    await setRegisterPoint(timestamp, 1234);
    const history = await Point.list({ year: 2021, month: 12, uid: uid });

    expect(history).to.be.an("array").lengthOf(1);
    expect(history[0].point).equals(1234);
    expect(history[0].timestamp).equals(timestamp);
  });

  it("Generate one point history of each events.", async () => {
    // Register event has already created.
    // Sign-in
    await setSignInPoint(dayjs().year(2021).month(11).date(1).unix(), 120);

    // Post create
    await setPostCreatePoint(dayjs().year(2021).month(11).date(2).unix(), 100);

    // Comment create
    await setCommentCreatePoint(dayjs().year(2021).month(11).date(3).unix(), 50);

    const history = await Point.list({ year: 2021, month: 12, uid: uid });

    expect(history).to.be.an("array").lengthOf(4);
  });

  it("Sign-in next day", async () => {
    // Sign-in on the next month
    await setSignInPoint(dayjs().year(2021).month(11).date(2).unix(), 120);

    const history = await Point.list({ year: 2021, month: 12, uid: uid });
    expect(history).to.be.an("array").lengthOf(5);
  });

  it("Sign-in on next month - no change on Dec, 2022.", async () => {
    // Sign-in on the next month (Jan, 2022)
    await setSignInPoint(dayjs().year(2022).month(0).date(2).unix(), 120);
    const history = await Point.list({ year: 2021, month: 12, uid: uid });
    expect(history).to.be.an("array").lengthOf(5);

    // one data for Jan, 2022
    const jan2022 = await Point.list({ year: 2022, month: 1, uid: uid });
    expect(jan2022).to.be.an("array").lengthOf(1);

    // No data for Feb, 2022
    const feb2022 = await Point.list({ year: 2022, month: 2, uid: uid });
    expect(feb2022).to.be.an("array").lengthOf(0);
  });

  it("2 Sign-in, 3 post create, 4 comment create on March, 2022.", async () => {
    // Sign-in
    await setSignInPoint(dayjs().year(2022).month(2).date(2).unix(), 120);
    await setSignInPoint(dayjs().year(2022).month(2).date(3).unix(), 120);
    const history = await Point.list({ year: 2022, month: 3, uid: uid });
    expect(history).to.be.an("array").lengthOf(2);

    // Post create
    await setPostCreatePoint(dayjs().year(2022).month(2).date(4).unix(), 100);
    await setPostCreatePoint(dayjs().year(2022).month(2).date(5).unix(), 100);
    await setPostCreatePoint(dayjs().year(2022).month(2).date(6).unix(), 100);
    const all5 = await Point.list({ year: 2022, month: 3, uid: uid });
    expect(all5).to.be.an("array").lengthOf(5);

    // Comment create
    await setCommentCreatePoint(dayjs().year(2022).month(2).date(7).unix(), 50);
    await setCommentCreatePoint(dayjs().year(2022).month(2).date(8).unix(), 50);
    await setCommentCreatePoint(dayjs().year(2022).month(2).date(9).unix(), 50);
    await setCommentCreatePoint(dayjs().year(2022).month(2).date(10).unix(), 50);

    const all9 = await Point.list({ year: 2022, month: 3, uid: uid });
    expect(all9).to.be.an("array").lengthOf(9);
  });

  it("History order test", async () => {
    console.log(
      "@TODO: 여기서 부터 - 시간 순서로 데이터를 가져오는 테스트. 오름차순 정렬로 보여준다."
    );
  });
});
