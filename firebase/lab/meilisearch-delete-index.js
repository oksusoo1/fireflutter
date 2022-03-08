const { MeiliSearch } = require("meilisearch");

const client = new MeiliSearch({
  host: "http://wonderfulkorea.kr:7700",
  apiKey: "",
});

// // An index is where the documents are stored.
// const index = client.index("posts");
client.deleteIndex("posts").catch((e) => {
  console.log(e);
});
client.deleteIndex("comments").catch((e) => {
  console.log(e);
});
client.deleteIndex("posts-and-comments").catch((e) => {
  console.log(e);
});
client.deleteIndex("users").catch((e) => {
  console.log(e);
});
