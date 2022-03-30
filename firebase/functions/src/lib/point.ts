import * as admin from "firebase-admin";
import { Ref } from "./ref";
import { Utils } from "./utils";

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
  static async signInPoint(after: any, context: any) {
    // console.log("data; ", after);
    const uid = context.params.uid;

    const signInRef = Ref.userPointSignIn(uid);

    if ((await Point.timePassed(signInRef, EventName.signIn)) === false) return null;
    const point = this.getRandomPoint(EventName.signIn);

    const docData = { timestamp: Utils.getTimestamp(), point: point };

    const ref = signInRef.push();
    await ref.set(docData);
    await this.updateUserPoint(uid, point);
    return ref;
  }

  /**
   * Returns user point. It returns 0 if there is no value.
   * @param {*} uid user id
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
   * `point` can be increase or decrease.
   * `history` is the total amount of point that the user earned in life time.
   * `history` is only increased. It does not decrease. So, it's good for computing user level.
   *
   * @param {*} uid uid
   * @param {*} point point to update
   */
  static updateUserPoint(uid: string, point: number) {
    console.log("path; ", Ref.userPoint(uid).key);
    return Ref.userPoint(uid).update({
      point: admin.database.ServerValue.increment(point),
      history: admin.database.ServerValue.increment(point),
    });
  }
}
