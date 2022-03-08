const { MeiliSearch } = require("meilisearch");

const client = new MeiliSearch({
  host: "http://wonderfulkorea.kr:7700",
  apiKey: "",
});

const indexUid = process.argv[2];
if (!indexUid) {
  console.log("Please provide an index.");
  process.exit(-1);
}

// // An index is where the documents are stored.
// const index = client.index("posts");
client
  .deleteIndex(indexUid)
  .then((v) => {
    console.log(indexUid + " index successfully deleted.");
  })
  .catch((e) => {
    console.log(e);
  });

// client.deleteIndex("comments").catch((e) => {
//   console.log(e);
// });
// client.deleteIndex("posts-and-comments").catch((e) => {
//   console.log(e);
// });
// client.deleteIndex("users").catch((e) => {
//   console.log(e);
// });
