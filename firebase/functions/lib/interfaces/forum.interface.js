"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CommentDocument = exports.PostDocument = void 0;
/**
 * Post document class for multi purpose.
 *
 * This can be used as a type like below.
 *
 * ```ts
 * const post = res2.data as PostDocument;
 * ```
 */
class PostDocument {
    constructor() {
        this.id = "";
        this.uid = "";
        this.category = "";
        this.hasPhoto = false;
        this.deleted = false;
        this.noOfComments = 0;
        this.year = 0;
        this.month = 0;
        this.day = 0;
        this.dayOfYear = 0;
        this.week = 0;
        this.point = 0;
    }
    fromDocument(doc, id) {
        var _a, _b, _c, _d, _e, _f;
        const obj = doc;
        obj.id = id;
        obj.uid = doc.uid;
        obj.category = doc.category;
        obj.subcategory = (_a = doc.subcategory) !== null && _a !== void 0 ? _a : "";
        obj.title = (_b = doc.title) !== null && _b !== void 0 ? _b : "";
        obj.content = (_c = doc.content) !== null && _c !== void 0 ? _c : "";
        obj.subcategory = (_d = doc.content) !== null && _d !== void 0 ? _d : "";
        obj.files = (_e = doc.files) !== null && _e !== void 0 ? _e : [];
        obj.hasPhoto = doc.hasPhoto;
        obj.deleted = doc.deleted;
        obj.noOfComments = doc.noOfComment;
        obj.year = doc.year;
        obj.month = doc.month;
        obj.day = doc.day;
        obj.dayOfYear = doc.dayOfYear;
        obj.week = doc.week;
        obj.createdAt = doc.createdAt;
        obj.updatedAt = doc.updatedAt;
        obj.point = (_f = doc.point) !== null && _f !== void 0 ? _f : 0;
        return obj;
    }
}
exports.PostDocument = PostDocument;
/**
 * Minimum
 */
// export interface PostCreateParams {
//   uid: string;
//   category: string;
//   subcategory?: string;
//   title?: string;
//   content?: string;
//   summary?: string;
//   files?: string[];
// }
// export interface PostCreateRequirements {
//   uid: string;
//   category: string;
//   subcategory?: string;
//   title?: string;
//   content?: string;
//   summary?: string;
//   files: string[];
//   hasPhoto: boolean;
//   deleted: false;
//   noOfComment: 0;
//   year: number;
//   month: number;
//   day: number;
//   dayOfYear: number;
//   week: number;
//   createdAt: admin.firestore.FieldValue;
//   updatedAt: admin.firestore.FieldValue;
// }
/**
 * A multi-purpose comment document interface representing the comment document of firebase.
 *
 */
class CommentDocument {
    constructor() {
        this.id = "";
        this.uid = "";
        this.postId = "";
        this.parentId = "";
        this.content = "";
        this.files = [];
        this.hasPhoto = false;
        this.deleted = false;
        this.point = 0;
    }
    fromDocument(data, id) {
        var _a, _b;
        const obj = new CommentDocument();
        obj.id = id;
        obj.uid = data.uid;
        obj.postId = data.postId;
        obj.parentId = data.parentId;
        obj.content = data.content;
        obj.files = (_a = data.files) !== null && _a !== void 0 ? _a : [];
        obj.hasPhoto = data.hasPhoto;
        obj.deleted = data.deleted;
        obj.createdAt = data.createdAt;
        obj.updatedAt = data.updatedAt;
        obj.point = (_b = data.point) !== null && _b !== void 0 ? _b : 0;
        return obj;
    }
}
exports.CommentDocument = CommentDocument;
//# sourceMappingURL=forum.interface.js.map