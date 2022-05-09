import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";

import { Test } from "../../src/classes/test";
import { CategoryDocument, PostDocument } from "../../src/interfaces/forum.interface";

new FirebaseAppInitializer();

let totalPosts: Array<PostDocument> = [];

let category: CategoryDocument;
let newCategory: CategoryDocument;

describe("Post list test", () => {
    it("Create some posts for test", async () => {
      // create 31 posts.
      category = await Test.createCategory();
      for (let i = 1; i <= 10; i++) {
        await Post.create({
          uid: "test-uid",
          category: category.id,
          title: "test-title-" + i,
        } as any);
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }
    });

    it("Get first page.", async () => {
      totalPosts = await Post.list({
        limit: 4,
      });

      // console.log(totalPosts[0]);
      for (let i = 0; i <= 3; i++) {
        expect(totalPosts[i])
            .to.be.an("object")
            .to.have.property("title")
            .equals("test-title-" + (10 - i));
      }
    });

    it("Get second page.", async () => {
      const posts = await Post.list({
        startAfter: totalPosts[totalPosts.length - 1].createdAt,
        limit: 4,
      });
      for (let i = 0; i <= 3; i++) {
        expect(posts[i])
            .to.be.an("object")
            .to.have.property("title")
            .equals("test-title-" + (6 - i));
      }
      totalPosts = [...totalPosts, ...posts];
    });

    it("Get third page.", async () => {
      const posts = await Post.list({
        category: category.id, // without category, it will include 9 more posts.
        startAfter: totalPosts[totalPosts.length - 1].createdAt,
        limit: 4,
      });

      expect(posts.length).is.equals(2);

      expect(posts[0]).to.be.an("object").to.have.property("title").equals("test-title-2");
      expect(posts[1]).to.be.an("object").to.have.property("title").equals("test-title-1");

      totalPosts = [...totalPosts, ...posts];
      expect(totalPosts.length).equals(10);
    });

    it("Gets data from unknown category.", async () => {
      const posts = await Post.list({
        category: "someCategory",
      });

      expect(posts.length).equals(0);
    });

    it("Gets data from new category category.", async () => {
      newCategory = await Test.createCategory();
      for (let i = 1; i <= 2; i++) {
        await Post.create({
          uid: "test-uid",
          category: newCategory.id,
          title: "test-title-x-" + i,
        } as any);
      }

      const posts = await Post.list({
        category: newCategory.id,
      });

      expect(posts.length).equals(2);
    });

    it("Gets data from all category.", async () => {
      const posts = await Post.list({});

      expect(posts[0]).to.be.an("object").to.have.property("title").equals("test-title-x-2");
      expect(posts[1]).to.be.an("object").to.have.property("title").equals("test-title-x-1");
      expect(posts[2]).to.be.an("object").to.have.property("title").equals("test-title-10");
    });

    it("Gets limited number of posts", async () => {
      const q1 = await Post.list({
        limit: 5,
      });
      expect(q1.length).equals(5);
      const q2 = await Post.list({
        limit: 2,
      });
      expect(q2.length).equals(2);
      const q3 = await Post.list({
        limit: 7,
      });
      expect(q3.length).equals(7);
    });
});

