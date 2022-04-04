"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Point = exports.randomPoint = exports.EventName = void 0;
const admin = require("firebase-admin");
const ref_1 = require("./ref");
const utils_1 = require("./utils");
class EventName {
}
exports.EventName = EventName;
EventName.register = "register";
EventName.signIn = "signIn";
EventName.postCreate = "postCreate";
EventName.commentCreate = "commentCreate";
// / Within is seconds.
exports.randomPoint = {
    // / When user registers, he gets random points between 1000 and 2000.
    [EventName.register]: {
        min: 1000,
        max: 2000,
    },
    [EventName.signIn]: {
        min: 50,
        max: 200,
        within: 60 * 60 * 24,
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
class Point {
    /**
     * Update sign-in bonus event.
     *
     * @param after after value of Document update
     * @param context context
     * @return Reference of the point history document
     */
    static async signInPoint(after, context) {
        // console.log("data; ", after);
        const uid = context.params.uid;
        const signInRef = ref_1.Ref.pointSignIn(uid);
        if ((await this.timePassed(signInRef, EventName.signIn)) === false)
            return null;
        const point = this.getRandomPoint(EventName.signIn);
        const docData = { timestamp: utils_1.Utils.getTimestamp(), point: point };
        const ref = signInRef.push();
        await ref.set(docData);
        await this.updateUserPoint(uid, point);
        return ref;
    }
    /**
     * Registration point event
     *
     * One time point event for new users.
     *
     * Note, it gives point only one time.
     *
     * @param {*} data The data of the document - /users/<uid>
     * @param {*} context The context.params.uid is the user's uid.
     *
     * @return reference of the point event document
     */
    static async registerPoint(data, context) {
        const uid = context.params.uid;
        const ref = ref_1.Ref.pointRegister(uid);
        const snapshot = await ref.get();
        if (snapshot.exists()) {
            // Registration point has already given.
            return null;
        }
        const point = this.getRandomPoint(EventName.register);
        const docData = { timestamp: utils_1.Utils.getTimestamp(), point: point };
        await ref.set(docData);
        await this.updateUserPoint(uid, point);
        return ref;
    }
    /**
     * Returns point document reference
     * @param data post data
     * @param context context
     * @returns reference of the point history document
     */
    static async postCreatePoint(data, context) {
        // Get data
        const uid = data.uid;
        const postId = context.params.postId;
        const postCreateRef = ref_1.Ref.pointPostCreate(uid);
        // Time didn't passed from last bonus point event? then don't do point event.
        if ((await this.timePassed(postCreateRef, EventName.postCreate)) === false)
            return null;
        const point = this.getRandomPoint(EventName.postCreate);
        const docData = { timestamp: utils_1.Utils.getTimestamp(), point: point };
        // New reference to create a history with postId.
        const ref = postCreateRef.child(postId);
        // Check if the post has already point event.
        // Note, this will not happen in production mode since it only works on `onCreate` event.
        // This is only for test and it might be commented out if you wish.
        const snapshot = await ref.get();
        if (snapshot.exists() && snapshot.val())
            return null;
        // Set(add) history of post document. so, it will not do it again within the limited time.
        await ref.set(docData);
        // Update user point.
        await this.updateUserPoint(uid, point);
        // Update the post with point. So, it can display on screen.
        await ref_1.Ref.postDoc(postId).update({ point: point });
        return ref;
    }
    /**
     * Returns point history document of the comment point event.
     *
     * @param data comment data (just created)
     * @param context context
     * @returns reference of point history of the comment point event.
     */
    static async commentCreatePoint(data, context) {
        const uid = data.uid;
        const commentId = context.params.commentId;
        // console.log("uid; ", uid, ", commentId", commentId);
        const commentCreateRef = ref_1.Ref.pointCommentCreate(uid);
        if ((await this.timePassed(commentCreateRef, EventName.commentCreate)) === false)
            return null;
        const point = this.getRandomPoint(EventName.commentCreate);
        const docData = { timestamp: utils_1.Utils.getTimestamp(), point: point };
        // Reference to create a history.
        const ref = commentCreateRef.child(commentId);
        // Check if the comment has already point event.
        // Note, this will not happen in production mode since it only works on `onCreate` event.
        // This is only for test and it might be commented out if you wish.
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
    static async updateUserPoint(uid, point) {
        await ref_1.Ref.userPoint(uid).update({
            point: admin.database.ServerValue.increment(point),
            history: admin.database.ServerValue.increment(point),
        });
        const snapshot = await ref_1.Ref.userPoint(uid).get();
        if (snapshot.exists()) {
            await ref_1.Ref.userDoc(uid).update({
                point: snapshot.val().point,
            });
        }
    }
}
exports.Point = Point;
//# sourceMappingURL=point.js.map