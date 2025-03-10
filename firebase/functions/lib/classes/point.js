"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Point = exports.randomPoint = void 0;
const admin = require("firebase-admin");
const ref_1 = require("./ref");
const utils_1 = require("./utils");
const dayjs = require("dayjs");
const point_interface_1 = require("../interfaces/point.interface");
// / Within is seconds.
exports.randomPoint = {
    // / When user registers, he gets random points between 1000 and 2000.
    [point_interface_1.EventName.register]: {
        min: 1000,
        max: 2000,
    },
    [point_interface_1.EventName.signIn]: {
        min: 50,
        max: 200,
        within: 60 * 60 * 24,
    },
    [point_interface_1.EventName.postCreate]: {
        min: 55,
        max: 155,
        within: 60 * 60,
    },
    [point_interface_1.EventName.commentCreate]: {
        min: 33,
        max: 88,
        within: 10 * 60,
    },
};
class Point {
    /**
     * Update sign-in bonus event.
     *
     * @param after after value of Document update
     * @param context context
     * @return Reference of the point history document
     * @reference see `tests/point/list.ts` for generating sign-in bonus point for test.
     */
    static async signInPoint(after, context) {
        // console.log("data; ", after);
        const uid = context.params.uid;
        const signInRef = ref_1.Ref.signInPoint(uid);
        if ((await this.timePassed(signInRef, point_interface_1.EventName.signIn)) === false)
            return null;
        const point = this.getRandomPoint(point_interface_1.EventName.signIn);
        const docData = { timestamp: utils_1.Utils.getTimestamp(), point: point };
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
    static async registerPoint(data, context) {
        const uid = context.params.uid;
        const ref = ref_1.Ref.registerPoint(uid);
        const snapshot = await ref.get();
        if (snapshot.exists()) {
            // Registration point has already given.
            return null;
        }
        const point = this.getRandomPoint(point_interface_1.EventName.register);
        const docData = { timestamp: utils_1.Utils.getTimestamp(), point: point };
        await ref.set(docData);
        await this.updateUserPoint(uid, point);
        return ref;
    }
    /**
     * Returns point document reference
     * @param category the category of the post
     * @param uid the uid of the post
     * @param postId the post id that had just been created.
     * @returns reference of the point history document or null if the point event didn't happen.
     * @reference see `tests/point/list.ts` for generating post creation bonus point for test.
     */
    static async postCreatePoint(category, uid, postId) {
        // Get ref of point folder.
        const postCreateRef = ref_1.Ref.postCreatePointHistory(uid);
        // Point document to add into point folder.
        const data = { timestamp: utils_1.Utils.getTimestamp() };
        // If category has point value, then use category point value.
        if (category.point) {
            data.point = category.point;
        }
        else {
            // Time didn't passed from last bonus point event? then don't do point event.
            if ((await this.timePassed(postCreateRef, point_interface_1.EventName.postCreate)) === false)
                return null;
            data.point = this.getRandomPoint(point_interface_1.EventName.postCreate);
        }
        // New reference (of point folder) to add(create) a history with postId.
        const ref = postCreateRef.child(postId);
        // Check if the post has already point event.
        // Note, this will not happen in production mode since it only works on `onCreate` event.
        // This is only for test and it might be commented out if you wish. It is not expensive anyway.
        const snapshot = await ref.get();
        if (snapshot.exists() && snapshot.val())
            return null;
        // Set(add) history of post document. so, it will not do it again within the limited time.
        await ref.set(data);
        // Update user point.
        await this.updateUserPoint(uid, data.point);
        // Update the post with point. So, it can display on screen.
        await ref_1.Ref.postDoc(postId).update({ point: data.point });
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
    static async commentCreatePoint(uid, commentId) {
        // console.log("uid; ", uid, ", commentId", commentId);
        const commentCreateRef = ref_1.Ref.commentCreatePointHistory(uid);
        if ((await this.timePassed(commentCreateRef, point_interface_1.EventName.commentCreate)) === false)
            return null;
        const point = this.getRandomPoint(point_interface_1.EventName.commentCreate);
        const docData = { timestamp: utils_1.Utils.getTimestamp(), point: point };
        // Reference to create a history.
        const ref = commentCreateRef.child(commentId);
        // Check if the comment has already point event.
        // Note, this will not happen in production mode since it only works on `onCreate` event.
        // This is only for test and it might be commented out if you wish. This is not expensive anyway.
        const snapshot = await ref.get();
        if (snapshot.exists() && snapshot.val())
            return null;
        // Set history and update point.
        await ref.set(docData);
        // Update user point
        await this.updateUserPoint(uid, point);
        // Update the post with point. So, it can display on screen.
        await ref_1.Ref.commentDoc(commentId).update({ point: point });
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
    static async getUserPoint(uid) {
        const snapshot = await ref_1.Ref.userPoint(uid).child("point").get();
        if (snapshot.exists()) {
            const val = snapshot.val();
            return val ? val : 0;
        }
        else {
            return 0;
        }
    }
    /**
     * Alias of getUserPoint
     * @param uid the user's uid
     * @returns 0 or point
     */
    static async current(uid) {
        return this.getUserPoint(uid);
    }
    /**
     * Returns random point of the point event
     * @param {*} eventName Point event name
     */
    static getRandomPoint(eventName) {
        return utils_1.Utils.getRandomInt(exports.randomPoint[eventName].min, exports.randomPoint[eventName].max);
    }
    /**
     * Returns true if time has passed.
     *
     * Point histories are saved on realtime database.
     *
     * @param {*} ref folder reference of event history.
     * @param {*} eventName event name
     */
    static async timePassed(ref, eventName) {
        const lastEventSnapshot = await ref.orderByChild("timestamp").limitToLast(1).once("value");
        if (lastEventSnapshot.exists()) {
            const docs = lastEventSnapshot.val();
            const keys = Object.keys(docs);
            if (keys.length > 0) {
                const previousTimestamp = docs[keys[0]].timestamp;
                const within = exports.randomPoint[eventName].within;
                // / Time has passed?
                if (previousTimestamp + within < utils_1.Utils.getTimestamp()) {
                    return true;
                }
                else {
                    return false;
                }
            }
        }
        return true;
    }
    /**
     * Updates user point and level.
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
    static async updateUserPoint(uid, point) {
        await ref_1.Ref.userPoint(uid).update({
            point: admin.database.ServerValue.increment(point),
            history: admin.database.ServerValue.increment(point),
        });
        const snapshot = await ref_1.Ref.userPoint(uid).get();
        if (snapshot.exists()) {
            await ref_1.Ref.userDoc(uid).update({
                point: snapshot.val().point,
                level: this.getLevel(snapshot.val().history),
            });
        }
    }
    /**
     * Update user point with reason and history in extra folder.
     *
     * See readme for details.
     *
     * @param uid the user uid
     * @param point the point
     * @param reason Why this point should be added?
     *
     * @usage
     *  - Use this to add point for payment.
     *  - Use this for job opening point deduction.
     *  - Use this for any kinds of point addition or deduction.
     *  - Use this for tests
     *
     * @example
     * ```ts
     *  await Point.extraPoint(user.id, 12000, "test");
     *  const currentPoint = await Point.current(user.id);
     *  console.log("current point; ", currentPoint);
     * ```
     */
    static async extraPoint(uid, point, reason) {
        // Add point history in `/point/<uid>/extra` folder why this point has been added.
        await ref_1.Ref.extraPointHistory(uid)
            .push()
            .set({ point: point, reason: reason, timestamp: utils_1.Utils.getTimestamp() });
        return this.updateUserPoint(uid, point);
    }
    /**
     * Returns the registration bonus point.
     * @param uid the user's uid
     * @returns point if exists or 0
     */
    static async getRegistrationPoint(uid) {
        var _a;
        const snapshot = await ref_1.Ref.registerPoint(uid).once("value");
        if (snapshot.exists()) {
            return (_a = snapshot.val().point) !== null && _a !== void 0 ? _a : 0;
        }
        return 0;
    }
    /**
     * Returns the last point event from `extra` folder.
     * @param uid the user's uid
     * @returns Document of point history of extra point folder.
     */
    static async getLastExtraPointEvent(uid) {
        const lastEventSnapshot = await ref_1.Ref.extraPointHistory(uid).limitToLast(1).once("value");
        if (lastEventSnapshot.exists()) {
            const docs = lastEventSnapshot.val();
            return docs[Object.keys(docs)[0]];
        }
        return null;
    }
    /**
     * Returns the level of the point.
     *
     * Point can be any number. and it returns the level based on the fomula in the function.
     *
     * @param point point to get level of
     * @returns level
     */
    static getLevel(point) {
        const seed = 1000;
        let acc = 0;
        for (let i = 1; i < 500; i++) {
            acc = seed * i + acc;
            if (point < acc)
                return i;
        }
        return 0;
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
    static async history(data) {
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
        const history = [];
        // Get history of registration
        const register = await this._getReistrationEventWithin(data.uid, startAt, endAt);
        if (register) {
            history.push(register);
        }
        // Get history of sign-in
        await this._getPointHistoryWithin(ref_1.Ref.signInPoint(data.uid), "signIn", history, startAt, endAt);
        // Get history of post create
        await this._getPointHistoryWithin(ref_1.Ref.postCreatePointHistory(data.uid), "postCreate", history, startAt, endAt);
        // Get history of comemnt create
        await this._getPointHistoryWithin(ref_1.Ref.commentCreatePointHistory(data.uid), "commentCreate", history, startAt, endAt);
        // Get history of extra point event like jobCreate, payment, test
        await this._getPointHistoryWithin(ref_1.Ref.extraPointHistory(data.uid), "extra", history, startAt, endAt);
        // After getting the point, it orders by timestamp.
        history.sort((a, b) => a.timestamp - b.timestamp);
        return history;
    }
    /**
     * Returns the document of registration point event.
     * @param uid uid of the user
     * @param startAt starting timestamp
     * @param endAt end timestamp
     * @returns document of registration point event.
     */
    static async _getReistrationEventWithin(uid, startAt, endAt) {
        const snapshot = await ref_1.Ref.registerPoint(uid).get();
        if (snapshot.exists()) {
            const val = snapshot.val();
            if (val.timestamp > startAt && val.timestamp < endAt) {
                val.eventName = "register";
                return val;
            }
            else {
                return null;
            }
        }
    }
    /**
     * Returns histories of point event.
     *
     * @param ref Reference of point history folder.
     * @param eventName Event name. it can be 'extra' for extra event. and it can be postCreate, commentCreate, signIn.
     * @param history Array to hold the history
     * @param startAt starting timestamp
     * @param endAt end timestamp
     * @returns None. It adds histories into history param.
     */
    static async _getPointHistoryWithin(ref, eventName, history, startAt, endAt) {
        const snapshot = await ref.orderByChild("timestamp").startAt(startAt).endAt(endAt).get();
        const val = snapshot.val();
        if (!val)
            return;
        for (const k of Object.keys(val)) {
            const v = val[k];
            v.key = k;
            v.eventName = eventName;
            history.push(v);
        }
    }
}
exports.Point = Point;
//# sourceMappingURL=point.js.map