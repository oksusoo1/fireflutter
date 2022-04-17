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
import { ExtraReason } from "../../src/interfaces/point.interface";

new FirebaseAppInitializer();

const uid = "point-list-test-a" + Utils.getTimestamp();

/**
 * Generate test registration bonus point.
 * @param timestamp timestamp
 * @param point set point
 */
async function setRegisterPoint(timestamp: number, point: number) {
  const ref = Ref.registerPoint(uid);
  const docData = { timestamp: timestamp, point: point };
  await ref.set(docData);
}

/**
 * Generate test sign-in bonus point.
 * @param timestamp timestamp
 * @param point set point
 */
async function setSignInPoint(timestamp: number, point: number) {
  const ref = Ref.signInPoint(uid).push();
  const docData = { timestamp: timestamp, point: point };
  await ref.set(docData);
}
/**
 * Generate test sign-in bonus point.
 * @param timestamp timestamp
 * @param point set point
 */
async function setPostCreatePoint(timestamp: number, point: number) {
  const ref = Ref.postCreatePointHistory(uid).push();
  const docData = { timestamp: timestamp, point: point };
  await ref.set(docData);
}
/**
 * Generate test sign-in bonus point.
 * @param timestamp timestamp
 * @param point set point
 */
async function setCommentCreatePoint(timestamp: number, point: number) {
  const ref = Ref.commentCreatePointHistory(uid).push();
  const docData = { timestamp: timestamp, point: point };
  await ref.set(docData);
}

/**
 * Generate test sign-in bonus point.
 * @param timestamp timestamp
 * @param point set point
 */
async function setExtraPoint(timestamp: number, point: number, reason: string) {
  const ref = Ref.extraPointHistory(uid).push();
  const docData = { timestamp: timestamp, point: point, reason: reason };
  await ref.set(docData);
}

describe("Point history test with: " + uid, () => {
  it("Register only - get histories", async () => {
    // Registration
    const timestamp = dayjs().year(2021).month(11).date(1).unix();
    await setRegisterPoint(timestamp, 1234);
    const history = await Point.history({ year: 2021, month: 12, uid: uid });

    expect(history).to.be.an("array").lengthOf(1);
    expect(history[0].point).equals(1234);
    expect(history[0].timestamp).equals(timestamp);
  });

  it("Generate one point history of each events.", async () => {
    // Register event has already created.
    // Sign-in
    await setSignInPoint(dayjs().year(2021).month(11).date(4).unix(), 40);

    // Post create
    await setPostCreatePoint(dayjs().year(2021).month(11).date(2).unix(), 20);

    // Comment create
    await setCommentCreatePoint(dayjs().year(2021).month(11).date(8).unix(), 80);

    const history = await Point.history({ year: 2021, month: 12, uid: uid });

    expect(history).to.be.an("array").lengthOf(4);
  });

  it("Sign-in next day", async () => {
    // Sign-in on the next month
    await setSignInPoint(dayjs().year(2021).month(11).date(2).unix(), 20);

    const history = await Point.history({ year: 2021, month: 12, uid: uid });
    expect(history).to.be.an("array").lengthOf(5);
  });

  it("Sign-in on next month - no change on Dec, 2022.", async () => {
    // Sign-in on the next month (Jan, 2022)
    await setSignInPoint(dayjs().year(2022).month(0).date(2).unix(), 120);
    const history = await Point.history({ year: 2021, month: 12, uid: uid });
    expect(history).to.be.an("array").lengthOf(5);

    // one data for Jan, 2022
    const jan2022 = await Point.history({ year: 2022, month: 1, uid: uid });
    expect(jan2022).to.be.an("array").lengthOf(1);

    // No data for Feb, 2022
    const feb2022 = await Point.history({ year: 2022, month: 2, uid: uid });
    expect(feb2022).to.be.an("array").lengthOf(0);
  });

  it("2 Sign-in, 3 post create, 4 comment create, and 2 extra on March, 2022.", async () => {
    // Sign-in
    await setSignInPoint(dayjs().year(2022).month(2).date(2).unix(), 102);
    await setSignInPoint(dayjs().year(2022).month(2).date(12).unix(), 112);
    const history = await Point.history({ year: 2022, month: 3, uid: uid });
    expect(history).to.be.an("array").lengthOf(2);

    // Post create
    await setPostCreatePoint(dayjs().year(2022).month(2).date(4).unix(), 104);
    await setPostCreatePoint(dayjs().year(2022).month(2).date(5).unix(), 105);
    await setPostCreatePoint(dayjs().year(2022).month(2).date(16).unix(), 116);
    const all5 = await Point.history({ year: 2022, month: 3, uid: uid });
    expect(all5).to.be.an("array").lengthOf(5);

    // Comment create
    await setCommentCreatePoint(dayjs().year(2022).month(2).date(10).unix(), 110);
    await setCommentCreatePoint(dayjs().year(2022).month(2).date(17).unix(), 117);
    await setCommentCreatePoint(dayjs().year(2022).month(2).date(8).unix(), 108);
    await setCommentCreatePoint(dayjs().year(2022).month(2).date(9).unix(), 109);

    // Extra point. test & jobCreate

    await setExtraPoint(dayjs().year(2022).month(2).date(9).unix(), 10000, "test");
    await setExtraPoint(dayjs().year(2022).month(2).date(9).unix(), -2000, ExtraReason.jobCreate);

    const all9 = await Point.history({ year: 2022, month: 3, uid: uid });
    expect(all9).to.be.an("array").lengthOf(11);
  });

  it("List by timestamp ascending order", async () => {
    const dec2021 = await Point.history({ year: 2021, month: 12, uid: uid });

    expect(dec2021[0].point == 1234).true;
    expect(dec2021[1].point == 20).true;
    expect(dec2021[2].point == 20).true;
    expect(dec2021[3].point == 40).true;
    expect(dec2021[4].point == 80).true;

    // 102, 104, 105, 108, 109, 110, 112, 116, 117
    const mar2022 = await Point.history({ year: 2022, month: 3, uid: uid });
    // console.log(mar2022);
    expect(mar2022[0].point == 102).true;
    expect(mar2022[1].point == 104).true;
    expect(mar2022[2].point == 105).true;
    expect(mar2022[3].point == 108).true;
    expect(mar2022[4].point == 109).true;
    // extra test
    expect(mar2022[5].point == 10000).true;
    // extra jobCreate
    expect(mar2022[6].point == -2000).true;
    expect(mar2022[7].point == 110).true;
    expect(mar2022[8].point == 112).true;
    expect(mar2022[9].point == 116).true;
    expect(mar2022[10].point == 117).true;
  });
});
