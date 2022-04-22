import { Meilisearch } from "./meilisearch/meilisearch";
const indexId = process.argv[2];

// run with npm, add (-- -dd) options to delete existing indexed documents.
// npm run meilisearch:delete-index:users
// npm run meilisearch:delete-index:posts
// npm run meilisearch:delete-index:comments

// run with ts-node, add (-dd) options to delete existing indexed documents.
// ts-node meilisearch-delete-index.ts users
// ts-node meilisearch-delete-index.ts posts
// ts-node meilisearch-delete-index.ts comments
// ts-node meilisearch-delete-index.ts posts-and-comments

if (!indexId) {
  console.log("[NOTICE]: Please provide an index. It's either posts, comments, users.");
  process.exit(-1);
} else {
  Meilisearch.deleteIndexedDocuments(indexId)
    .then((val) => {
      console.log("Documents under " + indexId + " index has beed deleted!");
      process.exit(0);
    })
    .catch((e) => console.error(e));
}