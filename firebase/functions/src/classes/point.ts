import * as admin from "firebase-admin";
import { Ref } from "./ref";
import { Utils } from "./utils";
import * as dayjs from "dayjs";

interface PointHistory {
  key?: string;
  eventName: string;
  point: number;
  timestamp: number;
}
export class EventName {
  static register = "register";
  static signIn = "signIn";
  static postCreate = "postCreate";
  static commentCreate = "commentCreate";
}

// / Within is seconds.
export const randomPoint = {
  // / When user registers, he gets random points between 1000 and 2000.
  [EventName.register]: {
    min: 1000,
    max: 2000,
  },
  [EventName.signIn]: {
    min: 50,
    max: 200,
    within: 60 * 60 * 24, // 24 hours
  },
  [EventName.postCreate]: {
    min: 55,
    max: 155,
    within: 60 * 60,
  },
  [EventName.commentCreate]: {
    min: 33,
    max: 88,
    within: 10 * 60,
  },
};

export class Point {
  /**
   * Update sign-in bonus event.
   *
   * @param after after value of Document update
   * @param context context
   * @return Reference of the point history document
   * @reference see `tests/point/list.ts` for generating sign-in bonus point for test.
   */
  static async signInPoint(after: any, context: any): Promise<null | admin.database.Reference> {
    // console.log("data; ", after);
    const uid = context.params.uid;

    const signInRef = Ref.pointSignIn(uid);

    if ((await this.timePassed(signInRef, EventName.signIn)) === false) return null;
    const point = this.getRandomPoint(EventName.signIn);

    const docData = { timestamp: Utils.getTimestamp(), point: point };

    const ref = signInRef.push();
    await ref.set(docData);
    await this.updateUserPoint(uid, point);
    return ref;
  }

  /**
   * Reigster bonus point event
   *
   * Call this method to give the user (of uid) registration bonus.
   * Once this method is called, the registration bonus point will
   * be given to the user and this will be given only one time.
   *
   * @param {*} data - This data param is no use. Just pass it as empty.
   * @param {*} context
   *  - `context.params.uid` is required and is the user's uid.
   *
   * @return reference of the point event document
   *
   * @reference see `tests/point/list.ts` for generating registration bonus point for test.
   */
  static async registerPoint(data: any, context: any): Promise<null | admin.database.Reference> {
    const uid = context.params.uid;
    const ref = Ref.pointRegister(uid);
    const snapshot = await ref.get();
    if (snapshot.exists()) {
      // Registration point has already given.
      return null;
    }
    const point = this.getRandomPoint(EventName.register);

    const docData = { timestamp: Utils.getTimestamp(), point: point };
    await ref.set(docData);
    await this.updateUserPoint(uid, point);
    return ref;
  }

  /**
   * Returns point document reference
   * @param data post data
   * @param context context
   * @returns reference of the point history document or null if the point event didn't happen.
   * @reference see `tests/point/list.ts` for generating post creation bonus point for test.
   */
  static async postCreatePoint(uid: string, postId: string) {
    // Get data
    const postCreateRef = Ref.pointPostCreate(uid);

    // Time didn't passed from last bonus point event? then don't do point event.
    if ((await this.timePassed(postCreateRef, EventName.postCreate)) === false) return null;
    const point = this.getRandomPoint(EventName.postCreate);
    const docData = { timestamp: Utils.getTimestamp(), point: point };

    // New reference to create a history with postId.
    const ref = postCreateRef.child(postId);

    // Check if the post has already point event.
    // Note, this will not happen in production mode since it only works on `onCreate` event.
    // This is only for test and it might be commented out if you wish. It is not expensive anyway.
    const snapshot = await ref.get();
    if (snapshot.exists() && snapshot.val()) return null;

    // Set(add) history of post document. so, it will not do it again within the limited time.
    await ref.set(docData);
    // Update user point.
    await this.updateUserPoint(uid, point);
    // Update the post with point. So, it can display on screen.
    await Ref.postDoc(postId).update({ point: point });

    return ref;
  }

  /**
   * Returns point history document of the comment point event.
   *
   * @param data comment data (just created)
   * @param context context
   * @returns reference of point history of the comment point event.
   * @reference see `tests/point/list.ts` for generating comment creation bonus point for test.
   */
  static async commentCreatePoint(uid: string, commentId: string) {
    // console.log("uid; ", uid, ", commentId", commentId);

    const commentCreateRef = Ref.pointCommentCreate(uid);
    if ((await this.timePassed(commentCreateRef, EventName.commentCreate)) === false) return null;
    const point = this.getRandomPoint(EventName.commentCreate);
    const docData = { timestamp: Utils.getTimestamp(), point: point };

    // Reference to create a history.
    const ref = commentCreateRef.child(commentId);

    // Check if the comment has already point event.
    // Note, this will not happen in production mode since it only works on `onCreate` event.
    // This is only for test and it might be commented out if you wish. This is not expensive anyway.
    const snapshot = await ref.get();
    if (snapshot.exists() && snapshot.val()) return null;

    // Set history and update point.
    await ref.set(docData);

    // Update user point
    await this.updateUserPoint(uid, point);

    // Update the post with point. So, it can display on screen.
    await Ref.commentDoc(commentId).update({ point: point });

    return ref;
  }

  /**
   * Returns user point.
   *
   * It returns 0 if there is no value.
   *
   * @usage Use this method on veriety case.
   *
   * @param {*} uid user id
   * @return 0 or point
   */
  static async getUserPoint(uid: string): Promise<number> {
    const snapshot = await Ref.userPoint(uid).child("point").get();
    if (snapshot.exists()) {
      const val = snapshot.val();
      return val ? val : 0;
    } else {
      return 0;
    }
  }

  /**
   * Returns random point of the point event
   * @param {*} eventName Point event name
   */
  static getRandomPoint(eventName: string) {
    return Utils.getRandomInt(randomPoint[eventName].min, randomPoint[eventName].max);
  }

  /**
   * Returns true if time has passed.
   *
   * Point histories are saved on realtime database.
   *
   * @param {*} ref folder reference of event history.
   * @param {*} eventName event name
   */
  static async timePassed(ref: any, eventName: string) {
    const lastEventSnapshot = await ref.orderByChild("timestamp").limitToLast(1).once("value");

    if (lastEventSnapshot.exists()) {
      const docs = lastEventSnapshot.val();

      const keys = Object.keys(docs);
      if (keys.length > 0) {
        const previousTimestamp = docs[keys[0]].timestamp;
        const within = randomPoint[eventName].within;

        // / Time has passed?
        if (previousTimestamp + within < Utils.getTimestamp()) {
          return true;
        } else {
          return false;
        }
      }
    }
    return true;
  }

  /**
   * Updates user point.
   *
   * `point` can be increase or decrease.
   * `history` is the total amount of point that the user earned in life time.
   *  - `history` is only increased. It does not decrease.
   *  - So, it's good for computing user level.
   *
   * @usage Use this method to increase or decrease user point in variety cases.
   *
   * @param {*} uid uid
   * @param {*} point point to update
   */
  static async updateUserPoint(uid: string, point: number): Promise<any> {
    await Ref.userPoint(uid).update({
      point: admin.database.ServerValue.increment(point),
      history: admin.database.ServerValue.increment(point),
    });
    const snapshot = await Ref.userPoint(uid).get();
    if (snapshot.exists()) {
      await Ref.userDoc(uid).update({
        point: snapshot.val().point,
      });
    }
  }

  /**
   * Returns the list of point history. see README.md for details.
   * @param data
   * - data.month as the month you want to dispaly the history of.
   * - data.year is the year.
   * - data.uid is the user's uid
   * - data.password is needed when it is being called by http request. For test, it is not.
   *
   * @note month starts with 1 and ends with 12, while on the test code the month is between 0 and 11.
   */
  static async history(data: any): Promise<Array<PointHistory>> {
    const startAt = dayjs()
        .year(data.year)
        .month(data.month - 1)
        .startOf("month")
        .unix();
    const endAt = dayjs()
        .year(data.year)
        .month(data.month - 1)
        .endOf("month")
        .unix();

    const history: Array<PointHistory> = [];

    const register = await this._getReistrationEventWithin(data.uid, startAt, endAt);
    if (register) {
      history.push(register);
    }

    await this._getPointHistoryWithin(Ref.pointSignIn(data.uid), "signIn", history, startAt, endAt);
    await this._getPointHistoryWithin(
        Ref.pointPostCreate(data.uid),
        "postCreate",
        history,
        startAt,
        endAt
    );
    await this._getPointHistoryWithin(
        Ref.pointCommentCreate(data.uid),
        "commentCreate",
        history,
        startAt,
        endAt
    );

    // After getting the point, it orders by timestamp.

    history.sort((a, b) => a.timestamp - b.timestamp);

    return history;
  }

  static async _getReistrationEventWithin(uid: string, startAt: number, endAt: number) {
    const snapshot = await Ref.pointRegister(uid).get();
    if (snapshot.exists()) {
      const val = snapshot.val();
      if (val.timestamp > startAt && val.timestamp < endAt) {
        val.eventName = "register";
        return val;
      } else {
        return null;
      }
    }
  }

  static async _getPointHistoryWithin(
      ref: admin.database.Reference,
      eventName: string,
      history: Array<PointHistory>,
      startAt: number,
      endAt: number
  ) {
    const snapshot = await ref.orderByChild("timestamp").startAt(startAt).endAt(endAt).get();
    const val = snapshot.val();
    if (!val) return;

    for (const k of Object.keys(val)) {
      const v = val[k];
      v.key = k;
      v.eventName = eventName;
      history.push(v);
    }
  }
}
