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

client
  .deleteIndex(indexUid)
  .then((v) => {
    console.log(indexUid + " index successfully deleted.");
  })
  .catch((e) => {
    console.log(e);
  });
