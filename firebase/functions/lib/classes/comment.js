"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Comment = void 0;
const admin = require("firebase-admin");
const ref_1 = require("./ref");
const defines_1 = require("../defines");
const forum_interface_1 = require("../interfaces/forum.interface");
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
            return new forum_interface_1.CommentDocument().fromDocument(snapshot.data(), ref.id);
        }
        else {
            return null;
        }
    }
    static async get(id) {
        const snapshot = await ref_1.Ref.commentDoc(id).get();
        if (snapshot.exists) {
            return new forum_interface_1.CommentDocument().fromDocument(snapshot.data(), id);
        }
        return null;
    }
}
exports.Comment = Comment;
//# sourceMappingURL=comment.js.map