import * as Meilisearch from "meilisearch";

// const indexUid = process.argv[2];
// const deleteOpt = process.argv[3];

// if (!indexUid) {
//   console.log("[NOTICE]: Please provide an index. It's either posts, comments, users.");
//   process.exit(-1);
// } else {
//   // Meilisearch.reIndex(indexUid, Meilisearch.deleteOptions.includes(deleteOpt));

//   // process.exit(0);

//   (() async {

//   })();
// }

const client = new Meilisearch.MeiliSearch({
  host: "http://wonderfulkorea.kr:7700",
});

client
  .index("users")
  .deleteAllDocuments()
  .then((val) => {
    console.log(val);
  })
  .catch((e) => {
    console.error(e);
  });
