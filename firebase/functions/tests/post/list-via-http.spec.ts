import axios from "axios";
import "mocha";
import { expect } from "chai";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

new FirebaseAppInitializer();

const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/postList";
// const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/postList";
describe("Post list test", () => {
  it("test listing content option", async () => {
    // Includes post content by default.
    let res = await axios.post(endpoint, { category: "qna", limit: 1 });
    expect("content" in res.data[0] === true).true;

    // Includes post'content.
    res = await axios.post(endpoint, { category: "qna", limit: 1, content: "Y" });
    expect("content" in res.data[0] === true).true;

    // Do not include post content.
    res = await axios.post(endpoint, { category: "qna", limit: 1, content: "N" });
    expect("content" in res.data[0] === false).true;
  });

  it("test listing author option", async () => {
    // Includes post author by default.
    let res = await axios.post(endpoint, { category: "qna", limit: 1 });
    expect("author" in res.data[0] === true).true;
    expect("authorLevel" in res.data[0] === true).true;
    expect("authorPhotoUrl" in res.data[0] === true).true;

    // Includes post author information.
    res = await axios.post(endpoint, { category: "qna", limit: 1, author: "Y" });
    expect("author" in res.data[0] === true).true;
    expect("authorLevel" in res.data[0] === true).true;
    expect("authorPhotoUrl" in res.data[0] === true).true;

    // Do not include post author information.
    res = await axios.post(endpoint, { category: "qna", limit: 1, author: "N" });
    expect("author" in res.data[0] === false).true;
    expect("authorLevel" in res.data[0] === false).true;
    expect("authorPhotoUrl" in res.data[0] === false).true;
  });
});
