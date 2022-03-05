"use strict";

const assert = require("assert");
const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

// This must come after initlization
const utils = require("../utils");

describe("Removing html tags", () => {
  it("simple html tag remove test", async () => {
    let content = "<p>oo</p>";
    assert.equal(utils.removeHtmlTags(content), "oo");
    content = "<p>o<div>o<span>u u</span><div><b>~</b></p>";
    assert.equal(utils.removeHtmlTags(content), "oou u~");
  });
});
