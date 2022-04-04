import { Meilisearch } from "./meilisearch/meilisearch";

const indexUid = process.argv[2];
const deleteOpt = process.argv[3];

if (!indexUid) {
  console.log("[NOTICE]: Please provide an index. It's either posts-and-comments, posts, comments, users.");
  process.exit(-1);
} else {
  Meilisearch.reIndex(indexUid, Meilisearch.deleteOptions.includes(deleteOpt));
}
