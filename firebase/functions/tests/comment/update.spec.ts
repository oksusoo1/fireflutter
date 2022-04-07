import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Comment } from "../../src/classes/comment";
import { ERROR_COMMENT_NOT_EXISTS, ERROR_EMPTY_ID, ERROR_EMPTY_UID, ERROR_NOT_YOUR_COMMENT } from "../../src/defines";
import { Utils } from "../../src/classes/utils";
import { CommentDocument } from "../../src/interfaces/forum.interface";

new FirebaseAppInitializer();

let comment: CommentDocument | null;
const uid = "test-uid-" + Utils.getTimestamp();

describe("comment update test", () => {
  it("Prepares to create a comment for testing", async () => {
    comment = await Comment.create({
      uid: uid,
      postId: "comment-id",
      parentId: "parent-id",
      content: "yo",
    } as any);
  });

  it("fail - empty id", async () => {
    try {
      await Comment.update({} as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_ID);
    }
  });

  it("fail - empty uid", async () => {
    try {
      await Comment.update({ id: "someId" } as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_UID);
    }
  });

  it("fail - comment not existing", async () => {
    try {
      await Comment.update({ id: "non-existing-id", uid: "some-uid" } as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_COMMENT_NOT_EXISTS);
    }
  });

  it("fail - wrong uid", async () => {
    try {
      await Comment.update({ id: comment!.id, uid: "some-uid" } as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_NOT_YOUR_COMMENT);
    }
  });

  it("success - comment update", async () => {
    const createdComment = await Comment.update({ id: comment!.id, uid: uid } as any);
    expect(createdComment).to.be.an("object");
    expect(createdComment.id).equals(comment!.id);
  });

  it("success - comment hasPhoto", async () => {
    const createdComment = await Comment.update({ id: comment!.id, uid: uid, files: ["someFiles.jpg"] } as any);
    expect(createdComment.hasPhoto).true;

    const updatedComment = await Comment.update({ id: comment!.id, uid: uid, files: [] } as any);
    expect(updatedComment.hasPhoto).false;
  });

  it("success - comment updatedAt change", async () => {
    const updateA = await Comment.update({ id: comment!.id, uid: uid, content: "Hello" } as any);
    expect(updateA.content).equals("Hello");
    expect(updateA.updatedAt).not.equals(comment!.updatedAt);

    await Utils.delay(1500);

    const updateB = await Comment.update({ id: comment!.id, uid: uid, content: "World" } as any);
    expect(updateB.content).equals("World");
    expect((updateB.updatedAt! as any)["_seconds"]).is.greaterThan((updateA.updatedAt! as any)["_seconds"]);
  });
});
