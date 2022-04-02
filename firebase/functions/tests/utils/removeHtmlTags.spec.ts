import "mocha";
import { expect } from "chai";

import { Utils } from "../../src/classes/utils";

describe("Remove html tags", () => {
  it("simple html tag remove test", async () => {
    let content = "<p>oo</p>";

    expect(Utils.removeHtmlTags(content)).to.be.equal("oo");
    content = "<p>o<div>o<span>u u</span><div><b>~</b></p>";
    expect(Utils.removeHtmlTags(content)).to.be.equal("oou u~");
    content = "<div class='p-2'>Some content here with <i>italic characters</i></div>";
    expect(Utils.removeHtmlTags(content)).to.be.equal("Some content here with italic characters");
  });
});
