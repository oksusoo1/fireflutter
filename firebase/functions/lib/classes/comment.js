"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Comment = void 0;
const admin = require("firebase-admin");
const ref_1 = require("./ref");
const defines_1 = require("../defines");
class Comment {
    /**
     * Creates a comment
     *
     * @param data comment doc data to be created
     * @returns comment doc data after create. Note that, it will contain post id.
     */
    static async create(data) {
        var _a, _b, _c;
        if (!data.uid)
            throw defines_1.ERROR_EMPTY_UID;
        const doc = {
            uid: data.uid,
            postId: data.postId,
            parentId: (_a = data.parentId) !== null && _a !== void 0 ? _a : "",
            content: (_b = data.content) !== null && _b !== void 0 ? _b : "",
            files: (_c = data.files) !== null && _c !== void 0 ? _c : [],
            hasPhoto: !!data.files,
            deleted: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        const ref = await ref_1.Ref.commentCol.add(doc);
        const snapshot = await ref.get();
        if (snapshot.exists) {
            const comment = snapshot.data();
            comment.id = ref.id;
            return comment;
        }
        else {
            return null;
        }
    }
    /**
     * Updates a comment
     *
     * @param data comment data to update with.
     * @returns updated comment doc data.
     */
    static async update(data) {
        if (!data.id)
            throw defines_1.ERROR_EMPTY_ID;
        if (!data.uid)
            throw defines_1.ERROR_EMPTY_UID;
        const id = data.id;
        const comment = await this.get(id);
        if (comment === null)
            throw defines_1.ERROR_COMMENT_NOT_EXISTS;
        if (comment.uid !== data.uid)
            throw defines_1.ERROR_NOT_YOUR_COMMENT;
        delete data.id;
        // updatedAt
        data.updatedAt = admin.firestore.FieldValue.serverTimestamp();
        // hasPhoto
        if (data.files && data.files.length) {
            data.hasPhoto = true;
        }
        else {
            data.hasPhoto = false;
        }
        await ref_1.Ref.commentDoc(id).update(data);
        const updated = await this.get(id);
        if (updated === null)
            throw defines_1.ERROR_UPDATE_FAILED;
        return updated;
    }
    static async get(id) {
        const snapshot = await ref_1.Ref.commentDoc(id).get();
        if (snapshot.exists) {
            const comment = snapshot.data();
            comment.id = id;
            return comment;
        }
        return null;
    }
}
exports.Comment = Comment;
//# sourceMappingURL=comment.js.map